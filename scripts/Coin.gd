extends Area2D

@export var score: int = 50

func _on_body_entered(body):
	if body is Player:
		body.change_score(score)
		$AnimatedSprite2D.set_animation("pick")
		$AudioStreamPlayer.play()


func _on_audio_stream_player_finished():
	queue_free()
