class_name terrain_renderer extends TileMap

@onready var terrain_map = $"../TerrainMap";

enum layers_IDs {
	GRASS = 0,
	HIGHLIGHT = 1,
	CURSOR = 2,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	terrain_map.terrain_updated.connect(render_terrain.bind())

func render_terrain():
	for x in terrain_map.MASTER_GRID_SIZE:
		for y in terrain_map.MASTER_GRID_SIZE:
			render_cell(terrain_map.decode_cell(Vector2i(x, y)))

func render_cell(cell: Cell):
	set_cell(layers_IDs.GRASS, cell.position, layers_IDs.GRASS, Vector2i(cell.hydration_stage,0));
	if cell.get_is_sunny():
		set_cell(layers_IDs.HIGHLIGHT, cell.position, layers_IDs.HIGHLIGHT, Vector2i(0,0));
	else:
		erase_cell(layers_IDs.HIGHLIGHT, cell.position);
