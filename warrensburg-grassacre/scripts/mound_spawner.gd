extends Node

@export var starting_interval: float = 10.0
@export var spawn_interval: float = 8.0
@export var min_interval: float = 3.0
@export var interval_variance: float = 0.8
@export var mound_scene: PackedScene
@export var tilemap: TileMapLayer

func _ready():
	spawn_loop()

func spawn_loop():
	var start = starting_interval + randf_range(-interval_variance, interval_variance)
	start = max(start, 1.0)
	await get_tree().create_timer(start).timeout
	spawn_mound()
	while true:
		var pct = tilemap.mow_percent() / 100.0
		var interval = lerp(spawn_interval, min_interval, pct)
		interval += randf_range(-interval_variance, interval_variance)
		interval = max(interval, 1.0)
		await get_tree().create_timer(interval).timeout
		spawn_mound()

func spawn_mound():
	var pos = tilemap.get_clear_position()
	var mound = mound_scene.instantiate()
	mound.position = pos
	get_parent().add_child(mound)
