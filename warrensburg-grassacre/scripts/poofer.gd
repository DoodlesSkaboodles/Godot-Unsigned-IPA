extends Node

var poof_scene = preload("res://scenes/poof.tscn")

func spawn_poof(pos: Vector2):
	var poof = poof_scene.instantiate()
	poof.position = pos
	get_tree().current_scene.add_child(poof)
