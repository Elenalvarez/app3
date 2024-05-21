extends Control

const PORT = 8531

@onready var host_button = $VBoxContainer/Host
@onready var join_button = $VBoxContainer/Join
@onready var play_button = $VBoxContainer/Play
@onready var player_name = $PlayerName
@onready var ip_server = $IpServer

@export var player_scene: PackedScene

var peer = ENetMultiplayerPeer.new()

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
	sendPlayerInformation.rpc_id(1, player_name.text, multiplayer.get_unique_id())

func connection_failed():
	print("Connection failed")

@rpc("any_peer")
func sendPlayerInformation(name: String, id: int):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name": name,
			"id": id,
			"score" : 0
		}
	
	if multiplayer.is_server():
		for i in GameManager.Players:
			sendPlayerInformation.rpc(GameManager.Players[i].name, i)

func disable_buttons(is_host: bool):
	if is_host:
		play_button.disabled = false
	host_button.disabled = true
	join_button.disabled = true

func hostGame():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, 4)
	
	if error != OK:
		print("cannot host: " + error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)	
	multiplayer.multiplayer_peer = peer
	print("Waiting for players...")
	

func _on_host_pressed():
	hostGame()
	sendPlayerInformation(player_name.text, multiplayer.get_unique_id())
	

func _on_join_pressed():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_server.text, PORT)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	disable_buttons(true)

func _on_play_pressed():
	select_level.rpc("res://scenes/levels/prueba.tscn")

func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

@rpc("any_peer", "call_local")
func select_level(file: String):
	get_tree().change_scene_to_file(file)


