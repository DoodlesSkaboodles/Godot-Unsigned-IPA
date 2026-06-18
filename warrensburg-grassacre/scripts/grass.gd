extends TileMapLayer

const UNMOWED_SOURCE_ID = 0
const MOWED_SOURCE_ID   = 1
const TILE_SIZE = 16

var blocked_cells := 0

func _ready():
	for obj in get_tree().get_nodes_in_group("architecture"):
		var _cell = local_to_map(to_local(obj.global_position))
		blocked_cells += 1

func mow_at(world_pos: Vector2, current_speed: float = 0.0) -> bool:
	var center = local_to_map(world_pos)
	var newly_mowed = false
	for dr in [-1, 0, 1]:
		for dc in [-1, 0, 1]:
			var cell = center + Vector2i(dc, dr)
			if get_cell_source_id(cell) == UNMOWED_SOURCE_ID:
				set_cell(cell, MOWED_SOURCE_ID, Vector2i(0, 0))
				newly_mowed = true
				flash_tile(cell)
	if newly_mowed:
		$GrassCrunch.pitch_scale = remap(current_speed, 0, 600, 0.3, 1.2)
		$GrassCrunch.play()
	return newly_mowed

func flash_tile(cell: Vector2i):
	var rect = ColorRect.new()
	rect.color = Color(1, 1, 1, 0.6)
	rect.size = Vector2(TILE_SIZE, TILE_SIZE)
	rect.position = map_to_local(cell) - Vector2(TILE_SIZE / 2.0, TILE_SIZE / 2.0)
	get_parent().add_child(rect)
	var tween = create_tween()
	tween.tween_property(rect, "color:a", 0.0, 0.3)
	tween.tween_callback(rect.queue_free)

func mow_percent() -> float:
	var total = get_used_cells().size() - blocked_cells
	var mowed = 0
	for cell in get_used_cells():
		if get_cell_source_id(cell) == MOWED_SOURCE_ID:
			mowed += 1
	if total <= 0: return 0.0
	return float(mowed) / float(total) * 100.0

func unmow_at(world_pos: Vector2, radius: float):
	var center = local_to_map(world_pos)
	var reach = int(radius / TILE_SIZE) + 1
	for dr in range(-reach, reach + 1):
		for dc in range(-reach, reach + 1):
			var cell = center + Vector2i(dc, dr)
			var cell_world = map_to_local(cell)
			if cell_world.distance_to(world_pos) < radius:
				if get_cell_source_id(cell) == MOWED_SOURCE_ID:
					set_cell(cell, UNMOWED_SOURCE_ID, Vector2i(0, 0))

func is_clear(pos: Vector2) -> bool:
	var space = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 20.0
	query.shape = shape
	query.transform = Transform2D(0, pos)
	query.collision_mask = 1
	var results = space.intersect_shape(query)
	return results.is_empty()

func get_clear_position(margin: float = 80.0) -> Vector2:
	var screen = get_tree().root.get_visible_rect().size
	var pos = Vector2(randf_range(margin, screen.x - margin), randf_range(margin, screen.y - margin))
	var attempts = 0
	while not is_clear(pos) and attempts < 10:
		pos = Vector2(randf_range(margin, screen.x - margin), randf_range(margin, screen.y - margin))
		attempts += 1
	return pos
