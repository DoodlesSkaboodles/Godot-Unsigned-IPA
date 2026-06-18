extends Area2D

var linked_robot: Node

func _on_body_entered(body):
	if body.is_in_group("mower"):
		Poofer.spawn_poof(global_position)
		print("linked_robot is: ", linked_robot)
		if linked_robot and is_instance_valid(linked_robot):
			linked_robot.deactivate()
		Autosound.play($Destroy.stream)
		queue_free()
