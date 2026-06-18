extends TileMapLayer

const UNMOWED_SOURCE_ID = 0
const MOWED_SOURCE_ID   = 1

func mow_at(world_pos: Vector2):
	var center = local_to_map(world_pos)
	for dr in [-1, 0, 1]:
		for dc in [-1, 0, 1]:
			var cell = center + Vector2i(dc, dr)
			if get_cell_source_id(cell) == UNMOWED_SOURCE_ID:
				set_cell(cell, MOWED_SOURCE_ID, Vector2i(0, 0))

func mow_percent() -> float:
	var total = 0
	var mowed = 0
	for cell in get_used_cells():
		total += 1
		if get_cell_source_id(cell) == MOWED_SOURCE_ID:
			mowed += 1
	if total == 0: return 0.0
	return float(mowed) / float(total) * 100.0
