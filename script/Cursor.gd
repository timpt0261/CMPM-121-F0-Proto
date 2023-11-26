extends Node2D

@onready var terrain_map = $"../../TerrainMap"
@onready var player = $"../Player"
@onready var terrainMap = preload("res://script/terrain_map.gd");
var mapFromMouse = Vector2i(0,0);

enum ACTIONS { PLAYER_MOVING, PLAYER_PLANTING };

var is_visible = true;
var move_player_command = Callable(movePlayer);
var plant_command = Callable(plant_plant);
var harvest_command = Callable(harvest_plant);
var current_command: Callable;

func _ready():
	current_command = Callable(do_nothing);

func _input(event):
	set_new_cursor_location();
	
	if(event.is_action_pressed("Move")):
		current_command = move_player_command;
	elif(event.is_action_pressed("Plant")):
		current_command = plant_command;
	elif(event.is_action_pressed("Harvest")):
		current_command = harvest_command;
	elif event.is_action_pressed("Select"):
		current_command.call();

func set_new_cursor_location():
	if (!is_visible): return;
	var newPos = terrain_map.local_to_map(get_global_mouse_position());
	if (mapFromMouse != newPos):
		terrain_map.erase_cell(terrain_map.layers_IDs.CURSOR, mapFromMouse);
		mapFromMouse = newPos;
	terrain_map.set_cell(2, mapFromMouse, 2, Vector2i(0,0));

func do_nothing():
	pass

func selecting():
	var map_from_mouse = terrain_map.local_to_map(get_global_mouse_position());
	if (map_from_mouse == terrain_map.local_to_map(player.global_position)):
		current_command = move_player_command;
		
func movePlayer():
	player.start_path();
	
func plant_plant():
	player.try_plant_plant(get_global_mouse_position());
	
func harvest_plant():
	player.try_harvest_plant(get_global_mouse_position());
	
