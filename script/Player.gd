extends Node2D
var aStarGrid: AStarGrid2D
var current_id_path: Array[Vector2i];

@onready var terrain_map = $"../../TerrainMap";
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
func _input(event):
	if event.is_action_pressed("Plant") == true:
		plant_manager.plant_plant(global_position);
		
func _physics_process(delta):
	move_from_path();

func start_path():	
	if (is_moving):
		return;
		
	var id_path
	var map_from_mouse = terrain_map.local_to_map(get_global_mouse_position());
	
	if (is_moving):
		id_path = aStarGrid.get_id_path(
		terrain_map.local_to_map(target_position),
		map_from_mouse
		)
	else:
		id_path = aStarGrid.get_id_path(
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
	
