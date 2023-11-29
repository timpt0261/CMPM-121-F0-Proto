extends Node2D

class_name game_state_manager

@onready var terrain_map = $"TerrainMap"
@onready var plant_manager = $"TerrainMap/Plants"

var cell_state_array: Array;

func _ready():
	var MASTER_GRID_SIZE = terrain_map.MASTER_GRID_SIZE
	cell_state_array = [];
	cell_state_array.resize(MASTER_GRID_SIZE*MASTER_GRID_SIZE)
	
func save_cell_state():
	var terrain_dict = terrain_map.terrain_dict
	var plant_dict = plant_manager.plantDict
	var MASTER_GRID_SIZE = terrain_map.MASTER_GRID_SIZE
	for key in terrain_dict:
		var g = terrain_dict[key]
		var growth = -1;
		var plant_type_id = -1
		if plant_dict.has(key as Vector2i):
			var p = plant_dict[key as Vector2i]
			growth = p.growth
			plant_type_id = p.plant_type_id
		var pos = key as Vector2
		var i = pos.y * MASTER_GRID_SIZE + pos.x
		cell_state_array[i] = cell_state_struct.new(g.get_wetness(), g.get_sunlight(), plant_type_id, growth)

func get_byte_array() -> PackedByteArray:
	return PackedByteArray(cell_state_array)

class cell_state_struct:
	var hydration: int
	var sun: int
	var plant_type_id: int
	var plant_growth: int
	
	func _init(hydration: int, sun: int, plant_type_id: int, plant_growth: int):
		self.hydration = hydration
		self.sun = sun
		self.plant_type_id = plant_type_id
		self.plant_growth = plant_growth
