extends Node

class_name game

var terrain_map: TileMap;
var cursor: Node;
var plant_manager: Node;

# Called when the node enters the scene tree for the first time.
func _ready():
	instantiate_plant_manager()
	instantiate_terrain_map(Vector2i(16, 16))
	instantiate_cursor()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func instantiate_terrain_map(size: Vector2i):
	var tile_set = preload("res://tile/tile_set.tres")
	
	terrain_map = TerrainMap.new();
	terrain_map.name = "terrain_map";
	terrain_map.tile_set = tile_set
	terrain_map.add_layer(-1)
	terrain_map.add_layer(-1)
	terrain_map.set_layer_name(0, "Grass")
	terrain_map.set_layer_name(1, "Highlight")
	terrain_map.set_layer_y_sort_origin(1, 40)
	terrain_map.set_layer_modulate(1, "ffffff18")
	terrain_map.set_layer_name(2, "Cursor")
	terrain_map.set_layer_z_index(2, 50)
	
	terrain_map.plant_manager = plant_manager
	
	add_child(terrain_map)

func instantiate_cursor():
	pass
	
func instantiate_plant_manager():
	plant_manager = Node2D.new()
	plant_manager.name = "plant_manager"
	plant_manager.set_script("res://script/plant_manager.gd")
	
	add_child(plant_manager)
