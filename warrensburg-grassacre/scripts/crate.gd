extends Node2D

const FORCE_THRESHOLD = 600.0
var hits = 0
var mower_inside = false

func _on_area_2d_body_entered(body):
	if body.is_in_group("mower") and not mower_inside:
		print("body entered: ", body.name)
		mower_inside = true
		take_hit(body.speed)

func _on_area_2d_body_exited(body):
	if body.is_in_group("mower"):
		mower_inside = false

func take_hit(speed: float):
	if speed < FORCE_THRESHOLD:
		return
	hits += 1
	if hits == 1:
		get_tree().get_first_node_in_group("score").add_points(50)
		$AnimatedSprite2D.play("broken")
		$CrateBreak.pitch_scale = randf_range(0.8, 1.2)
		$CrateBreak.play()
	elif hits >= 2:
		get_tree().get_first_node_in_group("score").add_points(100)
		poof()

func poof():
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.play("poofed")
	$Poof.play()
	await $AnimatedSprite2D.animation_finished
	queue_free()
