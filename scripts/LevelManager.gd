extends Node2D

@export var PlayerScene0: PackedScene
@export var PlayerScene1: PackedScene
@export var PlayerScene2: PackedScene
@export var PlayerScene3: PackedScene

var apple = load("res://scenes/coins/apple.tscn")
var banana = load("res://scenes/coins/banana.tscn")
var cherry = load("res://scenes/coins/cherry.tscn")
var orange = load("res://scenes/coins/orange.tscn")

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

func _process(delta):
	$Label.text = " %d:%02d " % [floor($Timer.time_left / 60), int($Timer.time_left) % 60]
	match int($Timer.time_left):
		110:
			if get_node("Fruits").get_child_count() == 4 : add_fruit()
		70:
			add_fruit()
		30:
			add_fruit()

func respawn(player: Player):
	var spawn_point_list = get_tree().get_nodes_in_group("PlayerSpawnPoint")
	player.global_position = spawn_point_list.pick_random().global_position
	player.death = false
	player.visible = true

func _on_fall_zone_body_entered(body):
	if body is Player:
		body.damage_ctrl()
		body.change_score(-25)

func _on_timer_timeout():
	get_tree().paused = true

func add_fruit():
	var fruits_list = [apple, banana, cherry, orange]
	var fruit = fruits_list.pick_random().instantiate()
	var worse_player
	var min_score: int = 100000
	var dist_min = 100000
	var fruits_spawn_list = get_tree().get_nodes_in_group("FruitSpawnPoint")
	var spawn_point
	
	for i in GameManager.Players:
		if int(GameManager.Players[i].score) < min_score:
			min_score = GameManager.Players[i].score
			worse_player = GameManager.Players[i].id
	
	var player_node = get_node("Players/" + str(worse_player))
	
	for i in fruits_spawn_list:
		var dist = i.global_position.distance_to(player_node.global_position)
		if int(dist) < dist_min:
			dist_min = dist
			spawn_point = i
	
	get_node("Fruits").add_child(fruit)
	fruit.global_position = spawn_point.global_position







