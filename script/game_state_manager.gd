extends Node2D
class_name game_state_manager

@onready var terrain_map = $TerrainMap
@onready var plant_manager = $TerrainMap/Plants
@onready var player = $TerrainMap/Player
@onready var tunr_count = $Lables/TurnCount
@onready var score_count = $Lables/ScoreCount

var cell_state_array: Array;

func _ready():
	var MASTER_GRID_SIZE = terrain_map.MASTER_GRID_SIZE
	cell_state_array = [];
	cell_state_array.resize(MASTER_GRID_SIZE*MASTER_GRID_SIZE)
	
func save_cell_state():
	var player_pos = player.position;
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
		cell_state_array[i] = cell_state_struct.new(g.get_wetness(), g.get_sunlight(), plant_type_id, growth);
	
		

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


#Turn Count
#Score Count
#Random seed (per turn?)
#Tile info
#Player Position
#Inventory (what seeds you have)
#Plants Growing, Plant Data
#Turn Cell's entire state into piece of data


func do_save():
	save_cell_state()
	# Encode the cell state array to a PackedByteArray
	var byte_array = get_byte_array()
	# Save the PackedByteArray to a file
	var file = FileAccess.open("res://saved_data/game_save.dat", FileAccess.WRITE);
	file.store_buffer(byte_array)
	file.close()

func do_load():
	# Read the PackedByteArray from the file
	var file:FileAccess;
	if file.file_exists("res://saved_data/game_save.dat"):
		file.open("res://saved_data/game_save.dat", FileAccess.READ);
		var byte_array = PackedByteArray(file.get_buffer(file.get_len()));
		file.close();
		# Decode the PackedByteArray and update the game state
		load_cell_state(byte_array);
	else:
		printerr("Save Not Found");

func load_cell_state(byte_array: PackedByteArray):
	# Clear existing state (if any) before loading
	cell_state_array.clear()

	# still working out

	# Update the game state using the loaded data
	update_game_state()

func update_game_state():
	# Update the terrain, plants, player, and other game state elements
	# based on the loaded cell state array
	var MASTER_GRID_SIZE = terrain_map.MASTER_GRID_SIZE
	for i in range(MASTER_GRID_SIZE * MASTER_GRID_SIZE):
		var pos = Vector2(i % MASTER_GRID_SIZE, i / MASTER_GRID_SIZE)
		var g = terrain_map.terrain_dict[pos]
		var cell_data = cell_state_array[i]

		# Update terrain and plant information
		g.set_wetness(cell_data.hydration)
		g.set_sunlight(cell_data.sun)

		if cell_data.plant_type_id >= 0:
			plant_manager.plant_plant(pos, cell_data.plant_type_id, cell_data.plant_growth)

	# Additional game state updates based on the loaded data
	var additional_data = cell_state_array[-1]  # Get the last element in the array
	tunr_count.text = str(additional_data.turn_count)
	score_count.text = str(additional_data.score_count)

