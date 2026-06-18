extends Area2D

func _on_body_entered(body):
	if body.is_in_group("mower"):
		body.enter_mud()

func _on_body_exited(body):
	if body.is_in_group("mower"):
		body.exit_mud()
