extends Area2D

var linger_duration = 8.0
var warning_duration = 2.0

func _ready():
	$Sprite2D.visible = false
	$CollisionShape2D.disabled = true
	$Warning.visible = false
	blink()
	await get_tree().create_timer(warning_duration).timeout
	$AnimationPlayer.stop()
	$Warning.visible = false
	$Sprite2D.frame = 0
	$Sprite2D.play("default")
	$Sprite2D.visible = true
	$Dirt.play()
	$CollisionShape2D.disabled = false
	await get_tree().create_timer(linger_duration).timeout
	queue_free()

func blink():
	$AnimationPlayer.play("blink")

func _on_body_entered(body):
	if body.is_in_group("mower"):
		Poofer.spawn_poof(global_position)
		Autosound.play($Destroy.stream)
		body.stun()
		queue_free()
