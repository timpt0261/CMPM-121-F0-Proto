extends Node2D
var aStarGrid: AStarGrid2D
var current_id_path: Array[Vector2i];

@onready var tile_map = $"../../TileMap";
@onready var turn_count = $"../../Labels/TurnCount";
@onready var plant_manager = $"../Plants";


var target_position: Vector2
var is_moving: bool

@export var max_move_range = 7;

const GRID_SPACE = Rect2i(0, 0, 16, 16)

func _ready():
	aStarGrid = AStarGrid2D.new()
	aStarGrid.region = Rect2i(0, 0, 16, 16)
	aStarGrid.cell_size = Vector2(16,16);
	aStarGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER;
	aStarGrid.update();



# Remove this as soon as I connect this to menus
#func _input(event):
#	if event.is_action_pressed("Plant") == true:
#		plant_manager.plant_plant(global_position);
		
func _physics_process(_delta):
	move_from_path();

func start_path():	
	if (is_moving):
		return;
		
	var id_path
	var map_from_mouse = tile_map.local_to_map(get_global_mouse_position());
	
	if (is_moving):
		id_path = aStarGrid.get_id_path(
		tile_map.local_to_map(target_position),
		map_from_mouse
		)
	else:
		id_path = aStarGrid.get_id_path(
		tile_map.local_to_map(global_position),
		map_from_mouse
		).slice(1);
	
	if (!id_path.is_empty() && id_path.size() <= max_move_range):
		current_id_path = id_path;
		turn_count.next_turn();

func move_from_path():
	if current_id_path.is_empty():
		return

	if (!is_moving):
		target_position = tile_map.map_to_local(current_id_path.front());
		is_moving = true;

	global_position = global_position.move_toward(target_position, 1);

	if (global_position == target_position):
		current_id_path.pop_front();
		
		if (!current_id_path.is_empty()):
			target_position = tile_map.map_to_local(current_id_path.front());
		else:
			is_moving = false;
			
func plant_plant(planting_pos: Vector2, type):
	var player_map_pos = tile_map.local_to_map(global_position);
	var planting_map_pos = tile_map.local_to_map(planting_pos);
	var distance_squrd = pow(planting_map_pos.x - player_map_pos.x, 2) + pow(planting_map_pos.y - player_map_pos.y, 2);
	if !is_moving && distance_squrd == 1:
		plant_manager.plant_plant(planting_pos);
		turn_count.next_turn();
