class_name Player extends Node2D
var current_id_path: Array[Vector2i];

@onready var terrain_map = $"../TerrainMap";
@onready var turn_count = $"../Labels/TurnCount";
var a_star: AStarWrapper = AStarWrapper.new();

var target_position: Vector2
var is_moving: bool

@export var move_speed = 2;
@export var max_move_range = 7;
		
func _physics_process(_delta):
	move_from_path();

func start_path():
	if (is_moving): return;
		
	var map_from_mouse = terrain_map.pixel_to_grid(get_global_mouse_position());
	var id_path: Array[Vector2i];
	
	if (is_moving): id_path = a_star.get_id_path(terrain_map.pixel_to_grid(target_position), map_from_mouse);
	else: id_path = a_star.get_id_path(get_player_map_pos(), map_from_mouse).slice(1);
	
	if (!id_path.is_empty() && id_path.size() <= max_move_range): current_id_path = id_path;

func move_from_path():
	if current_id_path.is_empty(): return;

	if (!is_moving):
		target_position = terrain_map.grid_to_pixel(current_id_path.front());
		is_moving = true;

	global_position = global_position.move_toward(target_position, move_speed);

	if (global_position == target_position):
		current_id_path.pop_front();
		
		if (!current_id_path.is_empty()):
			target_position = terrain_map.grid_to_pixel(current_id_path.front());
		else:
			is_moving = false;
			turn_count.next_turn();
			
func try_plant_plant(planting_pos: Vector2):
	var planting_map_pos: Vector2i = terrain_map.pixel_to_grid(planting_pos);
	if !is_moving && get_distance_squared(planting_map_pos, get_player_map_pos()) == 1:
		if terrain_map.plant_at(planting_map_pos, 0):
			turn_count.next_turn();

func try_harvest_plant(harvest_pos: Vector2):
	var harvest_map_pos: Vector2i = terrain_map.pixel_to_grid(harvest_pos);
	if !is_moving && get_distance_squared(harvest_map_pos, get_player_map_pos()) == 1:
		if(terrain_map.harvest_at(harvest_map_pos)):
			turn_count.next_turn();
		
func get_player_map_pos():
	return terrain_map.pixel_to_grid(global_position);
 
func get_distance_squared(pos1: Vector2i, pos2: Vector2i):
	var x_squared: float = pow(pos1.x - pos2.x, 2);
	var y_squared: float = pow(pos1.y - pos2.y, 2);
	return sqrt(x_squared + y_squared);

