class_name TerrainMap extends TileMap

@onready var grass = preload("res://script/grass.gd");
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
		set_cell(layersIDs.HIGHLIGHT, Vector2(x,y), layersIDs.HIGHLIGHT, Vector2i(0,0));
	terrainDict[str(Vector2(x,y))] = g;
	

func update_grass():
	var grass_instance: Grass;
	for key in terrainDict:
		grass_instance = terrainDict[key];
		grass_instance.randomize_tile_properties();
