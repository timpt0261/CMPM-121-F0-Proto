extends Node2D
class_name GameStateManager

@onready var terrain_map = $TerrainMap
@onready var player = $Player
@onready var turn_count = $"Labels/TurnCount"
@onready var score_count = $"Labels/ScoreCount"
@onready var MASTER_GRID_SIZE = terrain_map.MASTER_GRID_SIZE

#buttons
@onready var save: Button = $"UI/save"
@onready var load: Button = $"UI/load"
@onready var save_scroll_up: Button = $"UI/save_scroll_up"
@onready var save_to_load_label: Label = $"UI/save_to_load_label"
@onready var save_scroll_down: Button = $"UI/save_scroll_down"
@onready var undo: Button = $"UI/undo"
@onready var redo: Button = $"UI/redo"
@onready var language_options: OptionButton = $"UI/LanguageOptions"
@onready var controls_label: Label = $"Labels/Controls"
@onready var language_label: Label = $"Labels/Language"

var game_state_stacks: Array[GameStateArray] = []
var current_snapshot_index: int = -1

var game_state_array: GameStateArray

var auto_save_length: int = 5
var autosave_start: int  # 60 second in 1 min
var is_playing: bool

const SAVE_DIRECTORY = "res://save_data/"
const SAVE_FORMAT = ".txt"
const SAVE_PREFIX = "SAVE-"
const AUTOSAVE_PREFIX = "AUTOSAVE-"

var save_to_load_index: int
var save_to_load: String
var saves_list: PackedStringArray

var lang_data


func _ready():
	turn_count.new_turn_signal.connect(new_turn.bind())
	bind_buttons()

	init_language_options("res://langs/languages.json")
	
	save_to_load_index = 0
	refresh_saves_list()
	new_turn()
	autosave_start = Time.get_unix_time_from_system()
	is_playing = true

func new_turn():
	game_state_to_array()
	create_snapshot()

func game_state_to_array():
	game_state_array = GameStateArray.new()
	game_state_array.set_player_position(player.grid_position)
	game_state_array.set_turn_count(turn_count.turn_number)
	game_state_array.set_score_count(score_count.score)
	game_state_array.set_farm_grid(terrain_map.farm_grid)

func get_save_array() -> SaveFileArray:
	var save_file_array = SaveFileArray.new()
	save_file_array.set_current_snapshot(current_snapshot_index)
	save_file_array.set_snapshot_size(game_state_array.get_array_size())
	for i in game_state_stacks.size():
		save_file_array.add_snapshot(game_state_stacks[i])
	return save_file_array

func do_save(save_name: String):
	game_state_to_array()
	# Save the PackedByteArray to a file
	var file = FileAccess.open(SAVE_DIRECTORY + save_name + SAVE_FORMAT, FileAccess.WRITE)
	file.store_buffer(get_save_array().byte_array)
	file.close()
	refresh_saves_list()


func do_load():
	var save_filepath = SAVE_DIRECTORY + save_to_load + SAVE_FORMAT
	# Read the PackedByteArray from the file
	if FileAccess.file_exists(save_filepath):
		var file = FileAccess.open(save_filepath, FileAccess.READ)
		var save_file_array = SaveFileArray.from_byte_array(
			PackedByteArray(file.get_buffer(file.get_length()))
		)
		file.close()
		current_snapshot_index = save_file_array.get_current_snapshot()
		game_state_stacks = save_file_array.get_snapshots()
		game_state_array = game_state_stacks[current_snapshot_index]
		update_game_state()
	else:
		printerr("Save Not Found")


func create_snapshot():
	var snapshot = game_state_array
	game_state_stacks = game_state_stacks.slice(0, current_snapshot_index + 1)
	game_state_stacks.append(snapshot)
	current_snapshot_index = game_state_stacks.size() - 1


func update_game_state():
	player.set_grid_position(game_state_array.get_player_position())

	turn_count.set_turn(game_state_array.get_turn_count())
	score_count.set_score(game_state_array.get_score_count())

	terrain_map.set_farm_grid(game_state_array.get_farm_grid())


func _physics_process(delta):
	if is_playing:
		auto_save()


func manual_save():
	do_save(get_new_save_name(SAVE_PREFIX))


func auto_save():
	var time_passed = Time.get_unix_time_from_system() - autosave_start
	if time_passed > (auto_save_length * 60):
		print("AUTOSAVING...")
		do_save(get_new_save_name(AUTOSAVE_PREFIX))
		autosave_start = Time.get_unix_time_from_system()


func do_undo():
	# Should change the the current byte array to last one in stack
	if current_snapshot_index > 0:
		current_snapshot_index -= 1
		game_state_array = game_state_stacks[current_snapshot_index]
		update_game_state()


func do_redo():
	if current_snapshot_index < game_state_stacks.size() - 1:
		current_snapshot_index += 1
		game_state_array = game_state_stacks[current_snapshot_index]
		update_game_state()


func get_new_save_name(prefix: String) -> String:
	#jank workarond since GDScript lacks the a do while loop.
	#seriously, what language just doesnt have a do while????
	var candidate: String
	var save_number = 0
	while true:
		candidate = prefix + str(save_number)
		if !FileAccess.file_exists(SAVE_DIRECTORY + candidate + SAVE_FORMAT):
			break
		save_number += 1
	return candidate


func save_scroll(dir: int):
	var new_index = save_to_load_index + dir
	if new_index < 0 || new_index >= saves_list.size():
		return
	set_save_to_load(new_index)


func set_save_to_load(index: int):
	save_to_load_index = index
	if save_to_load_index >= 0:
		save_to_load = saves_list[save_to_load_index].split(".")[0]
		save_to_load_label.text = save_to_load
	else:
		save_to_load_label.text = "No Save Files"


func refresh_saves_list():
	saves_list = DirAccess.get_files_at(SAVE_DIRECTORY)
	if save_to_load_index < 0:
		save_to_load_index = 0
	if save_to_load_index >= saves_list.size():
		set_save_to_load(saves_list.size() - 1)
	set_save_to_load(save_to_load_index)
	
func bind_buttons():
	save.pressed.connect(manual_save.bind())
	load.pressed.connect(do_load.bind())
	save_scroll_up.pressed.connect(save_scroll.bind(1))
	save_scroll_down.pressed.connect(save_scroll.bind(-1))
	undo.pressed.connect(do_undo.bind())
	redo.pressed.connect(do_redo.bind())	
	language_options.item_selected.connect(set_language.bind())
	
	
func init_language_options(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	lang_data = JSON.parse_string(file.get_as_text())

	for n in range(lang_data.size()):	
		language_options.add_item(lang_data[n].get("language"))
	
	language_options.select(0)
	

func set_language(id):
	print("test")
	
	var lang: Dictionary = lang_data[id]
	save.text = lang.get("save")
	load.text = lang.get("load")
	score_count.translated_text = lang.get("score")
	score_count.translate_score()
	turn_count.translated_text = lang.get("turn")
	turn_count.translate_turn()
	undo.text = lang.get("undo")
	redo.text = lang.get("redo")
	language_label.text = lang.get("lang")
	
	controls_label.text = "Z: " + lang.get("move") + ", X: " + lang.get("plant") + ", C: " + lang.get("harvest");
	
	
