extends Node

@export var starting_interval: float = 6.0
@export var spawn_interval: float = 3.0
@export var min_interval: float = 0.8
@export var interval_variance: float = 0.4
@export var rabbit_scene: PackedScene
@export var tilemap: TileMapLayer

const INSET = 40.0

func _ready():
	spawn_loop()

func spawn_loop():
	var start = starting_interval + randf_range(-interval_variance, interval_variance)
	start = max(start, 0.3)
	await get_tree().create_timer(start).timeout
	spawn_rabbit()
	while true:
		var pct = tilemap.mow_percent() / 100.0
		var interval = lerp(spawn_interval, min_interval, pct)
		interval += randf_range(-interval_variance, interval_variance)
		interval = max(interval, 0.3)
		await get_tree().create_timer(interval).timeout
		spawn_rabbit()

func spawn_rabbit():
	var screen = get_tree().root.get_visible_rect().size
	var edge = randi() % 4
	var from: Vector2
	var to: Vector2
	match edge:
		0: from = Vector2(randf_range(0, screen.x), INSET);            to = Vector2(randf_range(0, screen.x), screen.y - INSET)
		1: from = Vector2(randf_range(0, screen.x), screen.y - INSET); to = Vector2(randf_range(0, screen.x), INSET)
		2: from = Vector2(INSET, randf_range(0, screen.y));             to = Vector2(screen.x - INSET, randf_range(0, screen.y))
		3: from = Vector2(screen.x - INSET, randf_range(0, screen.y)); to = Vector2(INSET, randf_range(0, screen.y))
	var rabbit = rabbit_scene.instantiate()
	get_parent().add_child(rabbit)
	rabbit.launch(from, to)
