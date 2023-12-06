class_name Cursor extends Node2D

@onready var terrain_renderer = $"../TerrainMap/TerrainRenderer"
@onready var player = $"../Player"

enum ACTIONS { PLAYER_MOVING, PLAYER_PLANTING };

var cursor_pixel_position: Vector2i
var cursor_grid_position: Vector2i
var on_grid: bool;
const OFF_GRID_POSITION = Vector2i.ONE * -1

var move_player_command = Callable(movePlayer);
var plant_command = Callable(plant_plant);
var harvest_command = Callable(harvest_plant);
var current_command: Callable;

var cursor_sprite: Sprite2D

func _ready():
	current_command = Callable(do_nothing);
	set_cursor_sprite()

func set_cursor_sprite():
	if cursor_sprite == null:
		cursor_sprite = Sprite2D.new()
		cursor_sprite.centered = false
		cursor_sprite.texture = load("res://tile/selected.png")
		add_child(cursor_sprite)
		cursor_sprite.hide()

func _input(event):
	update_cursor_location()
	if(event.is_action_pressed("Move")):
		current_command = move_player_command;
	elif(event.is_action_pressed("Plant")):
		current_command = plant_command;
	elif(event.is_action_pressed("Harvest")):
		current_command = harvest_command;
	elif event.is_action_pressed("Select"):
		current_command.call();

func update_cursor_location():
	cursor_pixel_position = get_global_mouse_position()
	if terrain_renderer.pixel_in_bounds(cursor_pixel_position):
		if !on_grid:
			on_grid = true
			cursor_sprite.show()
		cursor_grid_position = terrain_renderer.pixel_to_grid(cursor_pixel_position)
		cursor_sprite.position = terrain_renderer.grid_to_pixel(cursor_grid_position)
	elif on_grid:
		on_grid = false
		cursor_grid_position = OFF_GRID_POSITION
		cursor_sprite.hide()

func do_nothing():
	pass

func movePlayer():
	player.move_to(cursor_grid_position);

func plant_plant():
	player.try_plant_plant(get_global_mouse_position());

func harvest_plant():
	player.try_harvest_plant(get_global_mouse_position());
