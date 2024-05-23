extends Node2D

@export var PlayerScene0: PackedScene
@export var PlayerScene1: PackedScene
@export var PlayerScene2: PackedScene
@export var PlayerScene3: PackedScene

func _ready():
	var index = 0
	var players_scenes = [PlayerScene0, PlayerScene1, PlayerScene2, PlayerScene3]
	for i in GameManager.Players:
		var ind_player
		match GameManager.Players[i].character:
			"MaskGuy":
				ind_player = 0
			"NinjaFrog":
				ind_player = 1
			"PinkMan":
				ind_player = 2
			"VirtualGirl":
				ind_player = 3
		var currentPlayer = players_scenes[ind_player].instantiate()
		currentPlayer.name = str(GameManager.Players[i].id)
		get_node("Players").add_child(currentPlayer)
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
			if spawn.name == str(index):
				currentPlayer.global_position = spawn.global_position
		index += 1


func respawn(player: Player):
	var spawn_point_list = get_tree().get_nodes_in_group("PlayerSpawnPoint")
	player.global_position = spawn_point_list.pick_random().global_position
	player.death = false
	player.visible = true


func _on_fall_zone_body_entered(body):
	if body is Player:
		body.damage_ctrl()
