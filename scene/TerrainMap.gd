extends TileMap

@onready var grass = preload("res://scene/Grass.gd");

const MASTER_GRID_SIZE = 256;
var terrainDict = {};

enum layersIDs {
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
	set_cell(layersIDs.GRASS, Vector2(x,y), layersIDs.GRASS, Vector2i(g.tile_type,0));	
	
	if (g.sunny):
		set_cell(layersIDs.HIGHLIGHT, Vector2(x,y), layersIDs.HIGHLIGHT, Vector2i(0,0));
	terrainDict[str(Vector2(x,y))] = g;
