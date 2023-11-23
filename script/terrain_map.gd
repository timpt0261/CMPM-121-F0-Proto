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
			var g = Grass.new();
			set_grass(g, x,y);

func set_grass(g, x,y):
	erase_cell(layers_IDs.HIGHLIGHT, Vector2(x,y));
	
	set_cell(layers_IDs.GRASS, Vector2(x,y), layers_IDs.GRASS, Vector2i(g.tile_type,0));	

	if (g.sunny):
		set_cell(layers_IDs.HIGHLIGHT, Vector2(x,y), layers_IDs.HIGHLIGHT, Vector2i(0,0));
	terrain_dict[Vector2(x,y)] = g;
	
func get_grass(x,y):
	var key = Vector2(x,y);
	if (terrain_dict.has(key)):
		return terrain_dict[key];

func update_grass():
	for key in terrain_dict:
		var grass_instance = terrain_dict[key];
		grass_instance.randomize_tile_properties();
		set_grass(grass_instance, key.x, key.y);
