extends Node2D
var aStarGrid: AStarGrid2D
var current_id_path: Array[Vector2i];

@onready var tile_map = $"../../TileMap"
@onready var terrainMap = preload("res://scene/TerrainMap.gd");

var target_position: Vector2
var is_moving: bool

var mapFromMouse = Vector2i(0,0);

const GRID_SPACE = Rect2i(0, 0, 16, 16)

func _ready():
	aStarGrid = AStarGrid2D.new()
	aStarGrid.region = Rect2i(0, 0, 16, 16)
	aStarGrid.cell_size = Vector2(16,16);
	aStarGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER;
	aStarGrid.update();

func _input(event):
	if event.is_action_pressed("Move") == true:
		start_path();

func _physics_process(delta):
	move_from_path();

func start_path():	
	var id_path
	var mapFromMouse = tile_map.local_to_map(get_global_mouse_position());
	
	if (is_moving):
		id_path = aStarGrid.get_id_path(
		tile_map.local_to_map(target_position),
		mapFromMouse
		)
	else:
		id_path = aStarGrid.get_id_path(
		tile_map.local_to_map(global_position),
		mapFromMouse
		).slice(1);
	
	if (!id_path.is_empty()):
		current_id_path = id_path;

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
