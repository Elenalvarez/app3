extends Control

const PORT = 8531

@onready var join_button = $HBoxContainer2/Join
@onready var play_button = $HBoxContainer2/Play
@onready var player_name = $HBoxContainer/PlayerName
@onready var ip_server = $HBoxContainer/IpServer
@onready var characters = $HBoxContainer3
@onready var maskguy_button = $HBoxContainer3/MaskGuy
@onready var ninjafrog_button = $HBoxContainer3/NinjaFrog
@onready var pinkman_button = $HBoxContainer3/PinkMan
@onready var virtualgirl_button = $HBoxContainer3/VirtualGirl
@onready var wait_players = $WaitPlayers

var level1 = "res://scenes/levels/prueba.tscn"
var level2 = "res://scenes/levels/level2.tscn"

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	if "--server" in OS.get_cmdline_args():
		hostGame()

func peer_connected(id):
	print("Player connected " + str(id))

func peer_disconnected(id):
	print("Player disconnected " + str(id))
	GameManager.Players.erase(id)

func connected_to_server():
	print("Connected to server")
	sendPlayerInformation.rpc_id(1, player_name.text, multiplayer.get_unique_id(), "")

func connection_failed():
	print("Connection failed")

@rpc("any_peer")
func sendPlayerInformation(my_name: String, id: int, character: String):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name": my_name,
			"id": id,
			"score" : 0, 
			"character": character
		}
	else:
		GameManager.Players[id]["character"]= character
	
	if multiplayer.is_server():
		for i in GameManager.Players:
			sendPlayerInformation.rpc(GameManager.Players[i].name, i, GameManager.Players[i].character)

func hostGame():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, 4)
	
	if error != OK:
		print("cannot host: " + error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	print("Waiting for players...")

func _on_join_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_server.text, PORT)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	join_button.disabled = true
	characters.visible = true

func _on_play_pressed():
	if all_choose():
		var level_list = [level1, level2]
		select_level.rpc(level_list.pick_random())
	else:
		wait_players.visible = true
		await get_tree().create_timer(3).timeout
		wait_players.visible = false

@rpc("any_peer", "call_local")
func select_level(level: String):
	get_tree().change_scene_to_file(level)

@rpc("any_peer", "call_local")
func choose_character(character: String):
	match character:
		"MaskGuy":
			maskguy_button.disabled = true
		"NinjaFrog":
			ninjafrog_button.disabled = true
		"PinkMan":
			pinkman_button.disabled = true
		"VirtualGirl":
			virtualgirl_button.disabled = true

func all_choose():
	var ready = true
	for player in GameManager.Players:
		if GameManager.Players[player].character == "":
			ready = false
	return ready

func _on_mask_guy_pressed():
	choose_character.rpc("MaskGuy")
	sendPlayerInformation.rpc_id(1, player_name.text, multiplayer.get_unique_id(), "MaskGuy")
	ninjafrog_button.disabled = true
	pinkman_button.disabled = true
	virtualgirl_button.disabled = true
	play_button.disabled = false

func _on_ninja_frog_pressed():
	choose_character.rpc("NinjaFrog")
	sendPlayerInformation.rpc_id(1, player_name.text, multiplayer.get_unique_id(), "NinjaFrog")
	maskguy_button.disabled = true
	pinkman_button.disabled = true
	virtualgirl_button.disabled = true
	play_button.disabled = false

func _on_pink_man_pressed():
	choose_character.rpc("PinkMan")
	sendPlayerInformation.rpc_id(1, player_name.text, multiplayer.get_unique_id(), "PinkMan")
	maskguy_button.disabled = true
	ninjafrog_button.disabled = true
	virtualgirl_button.disabled = true
	play_button.disabled = false

func _on_virtual_girl_pressed():
	choose_character.rpc("VirtualGirl")
	sendPlayerInformation.rpc_id(1, player_name.text, multiplayer.get_unique_id(), "VirtualGirl")
	maskguy_button.disabled = true
	ninjafrog_button.disabled = true
	pinkman_button.disabled = true
	play_button.disabled = false
