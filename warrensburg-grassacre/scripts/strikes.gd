extends Node

var strikes = 0

func add_strike():
	strikes += 1
	$Strike.play()
	get_tree().get_first_node_in_group("hud").flash_strikes()
	get_tree().get_first_node_in_group("mower").shake(8.0, 0.4)
	get_tree().get_first_node_in_group("mower").blink_strike()
	if strikes >= 3:
		game_over()

func game_over():
	get_tree().get_first_node_in_group("mower").unlock()
	get_tree().call_deferred("change_scene_to_file", "res://scenes/game over.tscn")
