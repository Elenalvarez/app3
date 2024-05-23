extends CharacterBody2D
class_name Player

var axis: Vector2 = Vector2.ZERO
var death = false
var kill_score= 100
var timebar = false
var is_powered = false
var jump_count = 0
var max_jump = 2

@export var gui: CanvasLayer
@export var speed = 128
@export var gravity = 16
@export var jump = 368

@onready var sprite = $AnimatedSprite2D
@onready var audio_jump = $Audio/Jump
@onready var audio_hit = $Audio/Hit
@onready var timer = $Timer

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	if is_multiplayer_authority():
		gui.visible = true

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _process(delta):
	if death and is_multiplayer_authority():
		death_ctrl()
	else:
		motion_ctrl()
	
	if timebar:
		gui.get_node("timebar").value = timer.time_left * gui.get_node("timebar").max_value/timer.wait_time
		gui.get_node("timebar").visible = true
	else:
		gui.get_node("timebar").visible = false
	
	if is_on_floor():
		jump_count = 0

func _input(event):
	if not death and jump_count < max_jump and event.is_action_pressed("ui_accept") and is_multiplayer_authority():
		jump_ctrl(1)
		jump_count+= 1

func get_axis()-> Vector2:
	if is_multiplayer_authority():
		var vector = gui.get_node("Joystick").posVector
		axis.x = vector.x
	return axis.normalized()

func motion_ctrl():
	var temp = get_axis()
	if not temp.x == 0:
		sprite.scale.x = temp.x
	velocity.x = temp.x * speed
	velocity.y += gravity
	move_and_slide()
	
	if is_on_floor():
		if not temp.x == 0:
			sprite.set_animation("run")
		else:
			sprite.set_animation("idle")
	else:
		if velocity.y < 0:
			sprite.set_animation("jump")
		else:
			sprite.set_animation("fall")
	play_animation.rpc()

@rpc("any_peer")
func play_animation():
	sprite.play()

func death_ctrl():
	velocity.x = 0
	velocity.y += gravity
	move_and_slide()
	eliminate.rpc()

@rpc("call_local")
func eliminate():
	get_tree().create_timer(0,2).timeout
	visible = false
	get_parent().get_parent().respawn(self)

func jump_ctrl(power: float):
	velocity.y = -jump * power
	audio_jump.play()

func damage_ctrl():
	death = true
	sprite.set_animation("death")

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "death":
		pass


func _on_hit_point_body_entered(body):
	if body is Player and velocity.y >= 0 and body != self:
		audio_hit.play()
		body.damage_ctrl()
		change_score(body.kill_score)
		jump_ctrl(0.75)

func change_score(score: int):
	for i in GameManager.Players:
		if str(GameManager.Players[i].id) == name:
			GameManager.Players[i].score += score

@rpc("any_peer")
func send_score_information(id: int, score: int):
	if GameManager.Players.has(id):
		GameManager.Players[id]["score"]+= score
	
	if multiplayer.is_server():
		for i in GameManager.Players:
			send_score_information.rpc(i, GameManager.Players[i].score)

func make_big():
	is_powered = true
	scale *= 1.5
	timer.start()
	await timer.timeout
	scale /= 1.5
	timebar = false
	is_powered = false

func increase_speed():
	is_powered = true
	speed *= 2
	sprite.speed_scale *= 1.5
	timer.start()
	await timer.timeout
	speed /= 2
	sprite.speed_scale /= 1.5
	timebar = false
	is_powered = false

func super_jump():
	is_powered = true
	jump *= 1.25
	timer.start()
	await timer.timeout
	jump /= 1.25
	timebar = false
	is_powered = false

func shield():
	is_powered = true
	$AnimationPlayer.play("shield")
	timer.start()
	await timer.timeout
	timebar = false
	is_powered = false


