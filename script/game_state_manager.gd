extends Node2D
class_name GameStateManager

@onready var terrain_map = $TerrainMap;
@onready var plant_manager = $"TerrainMap/Plants";
@onready var player = $Player;
@onready var turn_count = $"Labels/TurnCount";
@onready var score_count = $"Labels/ScoreCount";
@onready var MASTER_GRID_SIZE = terrain_map.MASTER_GRID_SIZE;

var game_state_byte_array: GameStateArray

var auto_save_length:int = 5;
var autosave_start: int = 0; # 60 second in 1 min
var is_playing: bool = false;

func _ready():
	pass
	
func game_state_to_array():
	#player_pos first 12 bytes
	var player_pos = player.position;
	var turn_number = turn_count.turn_number;
	var score_number = plant_manager.get_plant_harvested_amount();
	var terrain_dict = terrain_map.terrain_dict
	var plant_dict = plant_manager.plantDict
	game_state_byte_array = GameStateArray.new(MASTER_GRID_SIZE)
	
	game_state_byte_array.push(player_pos)
	game_state_byte_array.push(turn_count.turn_number)
	game_state_byte_array.push(score_number)
	
	
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
			game_state_byte_array.push(hydration)
			game_state_byte_array.push(sunlight)
			game_state_byte_array.push(plant_type_id)
			game_state_byte_array.push(growth)


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
	file.store_buffer(game_state_byte_array.as_byte_array())
	file.close()

func do_load():
	# Read the PackedByteArray from the file
	var file:FileAccess;
	if file.file_exists("res://saved_data/game_save.dat"):
		file.open("res://saved_data/game_save.dat", FileAccess.READ);
		game_state_byte_array.set_byte_array(PackedByteArray(file.get_buffer(file.get_len())));
		file.close();
		update_game_state()
	else:
		printerr("Save Not Found");

func update_game_state():
	# Update the terrain, plants, player, and other game state elements
	player.position = game_state_byte_array.get_player_position()
	# based on the loaded cell state array
	var MASTER_GRID_SIZE = terrain_map.MASTER_GRID_SIZE
	for y in MASTER_GRID_SIZE:
		for x in MASTER_GRID_SIZE:
			var pos = Vector2i(x, y)
			var g = terrain_map.terrain_dict[pos]

			# Update terrain and plant information
			g.set_wetness(game_state_byte_array.get_hydration(pos))
			g.set_sunlight(game_state_byte_array.get_sunlight(pos))

			var plant_id = game_state_byte_array.get_plant_id(pos)
			if plant_id >= 0:
				plant_manager.plant_plant(pos, plant_id, game_state_byte_array.get_growth(pos))

	# Additional game state updates based on the loaded data
	turn_count.text = str(game_state_byte_array.get_turn_count())
	score_count.text = str(game_state_byte_array.get_score())
#
func _physics_process(delta):
	if(is_playing):
		auto_save()

func auto_save():
	var time_passed = Time.get_unix_time_from_system() - autosave_start;
	if(time_passed > (auto_save_length * 60)):
		do_save();
		autosave_start = Time.get_unix_time_from_system();
	
	
