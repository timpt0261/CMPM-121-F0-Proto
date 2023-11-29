class_name TerrainMap extends TileMap

@onready var grass = preload("res://script/Grass.gd");
@onready var plant_manager = $"Plants"

const MASTER_GRID_SIZE = 16;
var terrain_dict = {};

enum layers_IDs {
	GRASS = 0,
	HIGHLIGHT = 1,
	CURSOR = 2,
}

func _ready():
	for x in MASTER_GRID_SIZE:
		for y in MASTER_GRID_SIZE:
			init_grass(x,y);

func init_grass(x: int, y: int):
	var g = Grass.new(x,y);
	set_cell(layers_IDs.GRASS, Vector2(x,y), layers_IDs.GRASS, Vector2i(g.tile_type,0));	
	if (g.sunny):
		set_cell(layers_IDs.HIGHLIGHT, Vector2(x,y), layers_IDs.HIGHLIGHT, Vector2i(0,0));
	terrain_dict[Vector2(x,y)] = g;
	bind_arguments(g);
	
func get_grass(x,y):
	var key = Vector2(x,y);
	if (terrain_dict.has(key)):
		return terrain_dict[key];

func update_grass():
	for key in terrain_dict:
		var grass_instance = terrain_dict[key];
		grass_instance.randomize_tile_properties();

func draw_new_grass(g: Grass):
	erase_cell(layers_IDs.GRASS, Vector2(g.x,g.y));
	set_cell(layers_IDs.GRASS, Vector2(g.x,g.y), layers_IDs.GRASS, Vector2i(g.tile_type,0));
	
func erase_sun(g: Grass):
	erase_cell(layers_IDs.HIGHLIGHT, Vector2(g.x,g.y));

func draw_sun(g: Grass):
	set_cell(layers_IDs.HIGHLIGHT, Vector2(g.x,g.y), layers_IDs.HIGHLIGHT, Vector2i(0,0));
	
# TODO: Parametrize this better -- grasses should probably have a const instance of their coordinates
# Also: I bind the arguments here, but I need to still include arguments 
# when i emit from a Grass object. wtf?

func bind_arguments(g: Grass):
	var draw_grass_call: Callable = Callable(self, "draw_new_grass");
	draw_grass_call.bind(g);
	var draw_sun_call: Callable = Callable(self, "draw_sun");
	draw_sun_call.bind(g);
	var erase_sun_call: Callable = Callable(self, "erase_sun");
	erase_sun_call.bind(g);
	
	g.connect("grass_changed", draw_grass_call);
	g.connect("sun_given", draw_sun_call);
	g.connect("sun_taken", erase_sun_call);
