extends Node2D

var points = 100
var mower_inside = false

const FORCE_THRESHOLD = 600.0

func _on_area_2d_body_entered(body):
	if body.is_in_group("mower") and not mower_inside:
		mower_inside = true
		if body.speed >= FORCE_THRESHOLD:
			knock_over()

func _on_area_2d_body_exited(body):
	if body.is_in_group("mower"):
		mower_inside = false

func knock_over():
	get_tree().get_first_node_in_group("score").add_points(points)
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.visible = false
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play("poofed")
	Autosound.play($Collect.stream, randf_range(0.7, 1.3))
	await $AnimatedSprite2D.animation_finished
	queue_free()
