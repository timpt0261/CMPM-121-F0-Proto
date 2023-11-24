extends Node2D
var a_star_grid: AStarGrid2D
var current_id_path: Array[Vector2i];

@onready var terrain_map = $"../../TerrainMap";
@onready var turn_count = $"../../Labels/TurnCount";
@onready var plant_manager = $"../Plants";


var target_position: Vector2
var is_moving: bool

@export var max_move_range = 7;

const GRID_SIZE = 16;
const GRID_SPACE = Rect2i(0, 0, GRID_SIZE, GRID_SIZE)

func _ready():
	a_star_grid = AStarGrid2D.new()
	a_star_grid.region = GRID_SPACE
	a_star_grid.cell_size = Vector2(GRID_SIZE,GRID_SIZE);
	a_star_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER;
	a_star_grid.update();



		
func _physics_process(_delta):
	move_from_path();

func start_path():	
	if (is_moving):
		return;
		
	var id_path
	var map_from_mouse = terrain_map.local_to_map(get_global_mouse_position());
	
	if (is_moving):
		id_path = a_star_grid.get_id_path(
		terrain_map.local_to_map(target_position),
		map_from_mouse
		)
	else:
		id_path = a_star_grid.get_id_path(
		terrain_map.local_to_map(global_position),
		map_from_mouse
		).slice(1);
	
	if (!id_path.is_empty() && id_path.size() <= max_move_range):
		current_id_path = id_path;

func move_from_path():
	if current_id_path.is_empty():
		return

	if (!is_moving):
		target_position = terrain_map.map_to_local(current_id_path.front());
		is_moving = true;

	global_position = global_position.move_toward(target_position, 1);

	if (global_position == target_position):
		current_id_path.pop_front();
		
		if (!current_id_path.is_empty()):
			target_position = terrain_map.map_to_local(current_id_path.front());
		else:
			is_moving = false;
			turn_count.next_turn();
			
func try_plant_plant(planting_pos: Vector2):
	var player_map_pos: Vector2i = terrain_map.local_to_map(global_position);
	var planting_map_pos: Vector2i = terrain_map.local_to_map(planting_pos);
	var distance_squared: = pow(planting_map_pos.x - player_map_pos.x, 2) + pow(planting_map_pos.y - player_map_pos.y, 2);
	if !is_moving && distance_squared == 1 && !plant_manager.is_plant_at_pos(planting_map_pos):
		plant_manager.plant_plant(planting_map_pos);
		turn_count.next_turn();

func try_harvest_plant(harvest_pos: Vector2):
	var player_map_pos: Vector2i = terrain_map.local_to_map(global_position);
	var harvest_map_pos: Vector2i = terrain_map.local_to_map(harvest_pos);
	var distance_squared = pow(harvest_map_pos.x - player_map_pos.x, 2) + pow(harvest_map_pos.y - player_map_pos.y, 2);
	if !is_moving && distance_squared == 1 && plant_manager.is_plant_at_pos(harvest_map_pos):
		plant_manager.harvest_plant(harvest_map_pos);
		turn_count.next_turn();
