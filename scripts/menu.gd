extends Control

const PORT = 8531

@onready var join_button = $HBoxContainer2/Join
@onready var play_button = $HBoxContainer2/Play
@onready var player_name = $HBoxContainer/PlayerName
@onready var ip_server = $HBoxContainer/IpServer
@onready var characters = $HBoxContainer3
@onready var maskguy_button = $HBoxContainer3/MaskGuy

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
	sendPlayerInformation.rpc_id(1, player_name.text, multiplayer.get_unique_id(), "any")

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
		print(GameManager.Players[id]["character"])
	
	if multiplayer.is_server():
		for i in GameManager.Players:
			sendPlayerInformation.rpc(GameManager.Players[i].name, i, GameManager.Players[i].character)

func disable_buttons():
	characters.visible = true
	play_button.disabled = false
	join_button.disabled = true

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
	disable_buttons()

func _on_play_pressed():
	select_level.rpc("res://scenes/levels/prueba.tscn")

@rpc("any_peer", "call_local")
func select_level(file: String):
	get_tree().change_scene_to_file(file)

@rpc("any_peer", "call_local")
func choose_character(character: String):
	match character:
		"MaskGuy":
			maskguy_button.disabled = true
			sendPlayerInformation.rpc_id(1, player_name.text, multiplayer.get_unique_id(), character)

func _on_mask_guy_pressed():
	choose_character.rpc("MaskGuy")





