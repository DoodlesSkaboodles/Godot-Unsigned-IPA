extends Area2D

var points = 50

func _on_body_entered(body):
	if body.is_in_group("mower"):
		Poofer.spawn_poof(global_position)
		get_tree().get_first_node_in_group("score").add_points(points)
		Autosound.play($Collect.stream, randf_range(0.7, 1.3))
		queue_free()
