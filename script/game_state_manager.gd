extends Node2D
class_name GameStateManager

@onready var terrain_map = $TerrainMap;
@onready var player = $Player;
@onready var turn_count = $"Labels/TurnCount";
@onready var score_count = $"Labels/ScoreCount";
@onready var MASTER_GRID_SIZE = terrain_map.MASTER_GRID_SIZE;

#buttons
@onready var save:Button = $"UI/save";
@onready var load:Button = $"UI/load";
@onready var undo:Button = $"UI/undo";
@onready var redo:Button =$"UI/redo";

var game_state_stacks: Array[GameStateArray] = [];
var current_snapshot_index: int = -1;

var game_state_array: GameStateArray

var auto_save_length:int = 5;
var autosave_start: int; # 60 second in 1 min
var is_playing: bool = false;

func _ready():
	turn_count.new_turn_signal.connect(new_turn.bind())
	save.pressed.connect(do_save.bind());
	load.pressed.connect(do_load.bind());
	undo.pressed.connect(do_undo.bind());
	redo.pressed.connect(do_redo.bind());
	autosave_start = 0
	new_turn()
	
func new_turn():
		game_state_to_array()
		create_snapshot()
	
func game_state_to_array():
	game_state_array = GameStateArray.new()
	game_state_array.set_player_position(player.grid_position)
	game_state_array.set_turn_count(turn_count.turn_number)
	game_state_array.set_score_count(score_count.score)
	game_state_array.set_farm_grid(terrain_map.farm_grid)

func do_save():
	game_state_to_array()
	# Save the PackedByteArray to a file
	var file = FileAccess.open("res://save_data/game_save.txt", FileAccess.WRITE);
	file.store_buffer(game_state_array.byte_array)
	file.close()

func do_load():
	# Read the PackedByteArray from the file
	if FileAccess.file_exists("res://save_data/game_save.txt"):
		var file = FileAccess.open("res://save_data/game_save.txt", FileAccess.READ);
		game_state_array = GameStateArray.from_byte_array(PackedByteArray(file.get_buffer(file.get_length())));
		file.close();
		update_game_state()
	else:
		printerr("Save Not Found");
		
func create_snapshot():
	var snapshot = game_state_array;
	game_state_stacks.append(snapshot);
	current_snapshot_index = game_state_stacks.size() -1;
	
func update_game_state():
	player.set_grid_position(game_state_array.get_player_position())

	turn_count.set_turn(game_state_array.get_turn_count())
	score_count.set_score(game_state_array.get_score_count())
	
	terrain_map.set_farm_grid(game_state_array.get_farm_grid())

func _physics_process(delta):
	if(is_playing):
		auto_save()

func auto_save():
	var time_passed = Time.get_unix_time_from_system() - autosave_start;
	if(time_passed > (auto_save_length * 60)):
		do_save();
		autosave_start = Time.get_unix_time_from_system();

func do_undo():
	# Should change the the current byte array to last one in stack
	if current_snapshot_index > 0:
		current_snapshot_index -= 1
		game_state_array = game_state_stacks[current_snapshot_index];
		update_game_state();
	
func do_redo():
	if current_snapshot_index < game_state_stacks.size() - 1:
		current_snapshot_index += 1
		game_state_array = game_state_stacks[current_snapshot_index]
		update_game_state()
