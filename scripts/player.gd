extends CharacterBody2D
class_name Player

var axis: Vector2 = Vector2.ZERO
var death = false
var kill_score= 100

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

func _input(event):
	if not death and is_on_floor() and event.is_action_pressed("ui_accept") and is_multiplayer_authority():
		jump_ctrl(1)

func get_axis()-> Vector2:
	if is_multiplayer_authority():
		var vector = gui.get_node("Joystick").posVector
		axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
		axis.x = vector.x
	return axis.normalized()

func motion_ctrl():
	if not get_axis().x == 0:
		sprite.scale.x = get_axis().x
	velocity.x = get_axis().x * speed
	velocity.y += gravity
	move_and_slide()
	
	if is_on_floor():
		if not get_axis().x == 0:
			sprite.set_animation("run")
		else:
			sprite.set_animation("idle")
	else:
		if velocity.y < 0:
			sprite.set_animation("jump")
		else:
			sprite.set_animation("fall")
	play_animation.rpc()

@rpc("call_local")
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
	queue_free()

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
		change_score(kill_score)
		jump_ctrl(0.75)

func change_score(score: int):
	for i in GameManager.Players:
		if str(GameManager.Players[i].id) == name:
			GameManager.Players[i].score += score

func make_big():
	scale *= 1.5
	timer.start()
	await timer.timeout
	scale /= 1.5

func increase_speed():
	speed *= 2
	sprite.speed_scale *= 1.5
	timer.start()
	await timer.timeout
	speed /= 2
	sprite.speed_scale /= 1.5

func super_jump():
	jump *= 1.25
	timer.start()
	await timer.timeout
	jump /= 1.25

func shield():
	$AnimationPlayer.play("shield")


