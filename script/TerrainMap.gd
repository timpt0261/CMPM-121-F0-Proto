class_name TerrainMap extends TileMap

@onready var grass = preload("res://script/Grass.gd");
@onready var plant_manager = $"Plants"

const MASTER_GRID_SIZE = 256;
var terrain_dict = {};

enum layers_IDs {
	GRASS = 0,
	HIGHLIGHT = 1,
	CURSOR = 2,
}

func _ready():
	for x in MASTER_GRID_SIZE:
		for y in MASTER_GRID_SIZE:
			set_grass(x,y);

func set_grass(x,y):
	var g = Grass.new();
	set_cell(layers_IDs.GRASS, Vector2(x,y), layers_IDs.GRASS, Vector2i(g.tile_type,0));	
	
	if (g.sunny):
		set_cell(layers_IDs.HIGHLIGHT, Vector2(x,y), layers_IDs.HIGHLIGHT, Vector2i(0,0));
	terrain_dict[str(Vector2(x,y))] = g;

func refresh_terrain_map():
	for x in MASTER_GRID_SIZE:
		for y in MASTER_GRID_SIZE:
			set_grass(x,y);
