extends Node

@export var spawn_interval: float = 4.0
@export var max_weeds: int = 6
@export var weed_scene: PackedScene
@export var tilemap: TileMapLayer

func _ready():
	spawn_loop()

func spawn_loop():
	while true:
		await get_tree().create_timer(spawn_interval).timeout
		if get_tree().get_nodes_in_group("weed").size() < max_weeds:
			spawn_weed()

func spawn_weed():
	var unmowed = []
	for cell in tilemap.get_used_cells():
		if tilemap.get_cell_source_id(cell) == 0:
			unmowed.append(cell)
	if unmowed.size() == 0:
		return
	var pick = unmowed[randi() % unmowed.size()]
	var pos = tilemap.map_to_local(pick)
	if not tilemap.is_clear(pos):
		return
	var weed = weed_scene.instantiate()
	weed.position = pos
	get_parent().add_child(weed)
