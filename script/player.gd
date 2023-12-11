class_name Player extends Node2D

@onready var terrain_map = $"../TerrainMap"
@onready var turn_count = $"../Labels/TurnCount"

const PLAYER_START = Vector2i(7, 8)

var a_star: AStarWrapper
var current_id_path: Array[Vector2i]
var target_position: Vector2
var is_moving: bool

var grid_position: Vector2i

@export var move_speed = 2
@export var max_move_range = 7


func _ready():
	grid_position = PLAYER_START
	position = terrain_map.grid_to_pixel(grid_position)
	a_star = AStarWrapper.new()
	current_id_path = []


func _physics_process(_delta):
	move_from_path()


func set_grid_position(grid_position: Vector2i):
	self.grid_position = grid_position
	position = terrain_map.grid_to_pixel(self.grid_position)


func move_to(destination: Vector2i):
	if is_moving:
		return

	var id_path: Array[Vector2i]

	current_id_path = a_star.get_id_path(get_player_map_pos(), destination).slice(1)


func move_from_path():
	if current_id_path.is_empty():
		return

	if !is_moving:
		target_position = terrain_map.grid_to_pixel(current_id_path.front())
		is_moving = true

	global_position = global_position.move_toward(target_position, move_speed)

	if global_position == target_position:
		current_id_path.pop_front()

		if !current_id_path.is_empty():
			target_position = terrain_map.grid_to_pixel(current_id_path.front())
		else:
			is_moving = false
			grid_position = terrain_map.pixel_to_grid(position)
			turn_count.next_turn()


func get_random_plant_id() -> int:
	var rnd = RandomNumberGenerator.new();
	return rnd.randi_range(0, PlantTemplates.get_templates().size()-1)

func try_plant_plant(planting_pos: Vector2):
	var planting_map_pos: Vector2i = terrain_map.pixel_to_grid(planting_pos)
	if !is_moving && get_distance_squared(planting_map_pos, get_player_map_pos()) == 1:
		if terrain_map.plant_at(planting_map_pos, get_random_plant_id()):
			turn_count.next_turn()


func try_harvest_plant(harvest_pos: Vector2):
	var harvest_map_pos: Vector2i = terrain_map.pixel_to_grid(harvest_pos)
	if !is_moving && get_distance_squared(harvest_map_pos, get_player_map_pos()) <= 1:
		if terrain_map.harvest_at(harvest_map_pos):
			turn_count.next_turn()


func get_player_map_pos():
	return terrain_map.pixel_to_grid(global_position)


func get_distance_squared(pos1: Vector2i, pos2: Vector2i):
	var x_squared: float = pow(pos1.x - pos2.x, 2)
	var y_squared: float = pow(pos1.y - pos2.y, 2)
	return sqrt(x_squared + y_squared)
