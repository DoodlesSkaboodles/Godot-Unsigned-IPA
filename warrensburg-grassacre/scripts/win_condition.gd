extends Node

@export var tilemap: TileMapLayer
@export var win_threshold: float = 90.0

func _process(_delta):
	if tilemap.mow_percent() >= win_threshold:
		Gamedata.score = get_tree().get_first_node_in_group("score").score
		Gamedata.strikes = get_tree().get_first_node_in_group("strikes").strikes
		get_tree().get_first_node_in_group("mower").unlock()
		get_tree().call_deferred("change_scene_to_file", "res://scenes/win screen.tscn")
