extends CharacterBody2D
class_name Player

var axis: Vector2 = Vector2.ZERO
var death = false

@export var gui: CanvasLayer
@export var speed = 128
@export var gravity = 16
@export var jump = 368

@onready var sprite = $AnimatedSprite2D
@onready var audio_jump = $Audio/Jump
@onready var audio_hit = $Audio/Hit

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())

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
		axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
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
	sprite.play()

func death_ctrl():
	velocity.x = 0
	velocity.y += gravity
	move_and_slide()

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
	if body is Enemy and velocity.y >= 0:
		audio_hit.play()
		body.damage_ctrl(1)
		jump_ctrl(0.75)
