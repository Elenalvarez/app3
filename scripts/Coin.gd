extends Area2D

@export var score: int = 50
@export var function: String

func _on_body_entered(body):
	if body is Player:
		body.change_score(score)
		$AnimatedSprite2D.set_animation("pick")
		$AudioStreamPlayer.play()
		match function:
			"big":
				make_big(body)
			"speed":
				increase_speed(body)
			"jump":
				super_jump(body)
			"shield":
				shield(body)

func make_big(player: Player):
	player.make_big()

func increase_speed(player: Player):
	player.increase_speed()

func super_jump(player: Player):
	player.super_jump()

func shield(player: Player):
	player.shield()

func _on_animated_sprite_2d_animation_finished():
	queue_free()
