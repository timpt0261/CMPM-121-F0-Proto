extends Node2D
class_name game_state_manager

@onready var terrain_map = $TerrainMap;
@onready var plant_manager = $TerrainMap/Plants;
@onready var player = $TerrainMap/Player;
@onready var turn_count = $"../Labels/TurnCount";
@onready var MASTER_GRID_SIZE = terrain_map.MASTER_GRID_SIZE;

var cell_state_array: Array;
var cell_state_byte_array: PackedByteArray

func _ready():
	cell_state_array = [];
	cell_state_array.resize(MASTER_GRID_SIZE*MASTER_GRID_SIZE)
	game_state_to_array()
	
func game_state_to_array():
	#player_pos first 12 bytes
	var player_pos = player.position;
	var turn_number = turn_count.turn_number;
	var score_number = plant_manager.get_plant_harvested_amount();
	var terrain_dict = terrain_map.terrain_dict
	var plant_dict = plant_manager.plantDict
	cell_state_byte_array = PackedByteArray()
	
	cell_state_byte_array.append_array(var_to_bytes(player_pos))
	cell_state_byte_array.append_array(var_to_bytes(turn_count.turn_number))
	cell_state_byte_array.append_array(var_to_bytes(score_number))
	
	
	#32 bytes per cell
	for y in MASTER_GRID_SIZE:
		for x in MASTER_GRID_SIZE:
			var pos = Vector2i(x, y)
			var c = terrain_dict[pos]
			var hydration = c.get_wetness()
			var sunlight = c.get_sunlight()
			var growth = -1;
			var plant_type_id = -1
			if plant_dict.has(pos):
				var p = plant_dict[pos]
				growth = p.growth
				plant_type_id = p.plant_type_id
			cell_state_byte_array.append_array(var_to_bytes(hydration))
			cell_state_byte_array.append_array(var_to_bytes(sunlight))
			cell_state_byte_array.append_array(var_to_bytes(plant_type_id))
			cell_state_byte_array.append_array(var_to_bytes(growth))


#Turn Count
#Score Count
#Random seed (per turn?)
#Tile info
#Player Position
#Inventory (what seeds you have)
#Plants Growing, Plant Data
#Turn Cell's entire state into piece of data


func do_save():
	game_state_to_array()
	# Save the PackedByteArray to a file
	var file = FileAccess.open("res://saved_data/game_save.dat", FileAccess.WRITE);
	file.store_buffer(cell_state_byte_array)
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
#	update_game_state()

#func update_game_state():
#	# Update the terrain, plants, player, and other game state elements
#	# based on the loaded cell state array
#	var MASTER_GRID_SIZE = terrain_map.MASTER_GRID_SIZE
#	for i in range(MASTER_GRID_SIZE * MASTER_GRID_SIZE):
#		var pos = Vector2(i % MASTER_GRID_SIZE, i / MASTER_GRID_SIZE)
#		var g = terrain_map.terrain_dict[pos]
#		var cell_data = cell_state_array[i]
#
#		# Update terrain and plant information
#		g.set_wetness(cell_data.hydration)
#		g.set_sunlight(cell_data.sun)
#
#		if cell_data.plant_type_id >= 0:
#			plant_manager.plant_plant(pos, cell_data.plant_type_id, cell_data.plant_growth)
#
#	# Additional game state updates based on the loaded data
#	var additional_data = cell_state_array[-1]  # Get the last element in the array
#	tunr_count.text = str(additional_data.turn_count)
#	score_count.text = str(additional_data.score_count)
#
