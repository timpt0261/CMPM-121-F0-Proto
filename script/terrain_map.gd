class_name TerrainMap extends Node2D

signal terrain_updated

@onready var plant_manager = $"Plants"
@onready var terrain_renderer  = $"TerrainRenderer"

const MASTER_GRID_SIZE = 16;

var terrain_array: PackedByteArray

enum CELL_PROPERTIES {
	HYDRATION = 0,
	SUNLIGHT = 1,
	PLANT_TYPE_ID = 2,
	PLANT_GROWTH = 3,
	PLANT_TURNS_ALIVE = 4
}
var plant_template_list;

func _ready():
	($"../Labels/TurnCount").next_turn_signal.connect(update_grid.bind())
	plant_template_list = get_plant_list("res://data/plants.json");
	create_new_terrain_grid()

#+------------------------------------------------------------------------------+
#|                              Terrain Management                              |
#+------------------------------------------------------------------------------+
func create_new_terrain_grid():
	terrain_array.resize(MASTER_GRID_SIZE * MASTER_GRID_SIZE * CELL_PROPERTIES.size())
	for x in MASTER_GRID_SIZE:
		for y in MASTER_GRID_SIZE:
			encode_cell(Cell.new(Vector2i(x, y)))
	terrain_updated.emit()

func update_grid():
	for x in MASTER_GRID_SIZE:
		for y in MASTER_GRID_SIZE:
			var cell_instance = decode_cell(Vector2i(x, y))
			cell_instance.randomize_tile_properties()
			encode_cell(cell_instance)
	terrain_updated.emit()
	
func get_grass(x,y) -> Cell:
	if x < 0 || x >= MASTER_GRID_SIZE || y < 0 || y >= MASTER_GRID_SIZE:
		return null
	else:
		return decode_cell(Vector2i(x, y));

#+------------------------------------------------------------------------------+
#|                                    Plants                                    |
#+------------------------------------------------------------------------------+
func get_plant_texture(plant_position: Vector2i) -> Texture2D:
	var cell = decode_cell(plant_position)
	var plant_type_id = cell.plant_type_id
	var plant_template = plant_template_list[plant_type_id]
	
	return plant_template.get("sprite")

func get_plant_list (file_path: String) -> Array:
	var file = FileAccess.open(file_path, FileAccess.READ);
	return JSON.parse_string(file.get_as_text());

#+------------------------------------------------------------------------------+
#|                       Byte Array encoding and decoding                       |
#+------------------------------------------------------------------------------+

# ---ENCODING---
func encode_cell(cell: Cell):
	encode_cell_property(cell.position, CELL_PROPERTIES.HYDRATION, cell.get_hydration())
	encode_cell_property(cell.position, CELL_PROPERTIES.SUNLIGHT, cell.get_sunlight())
	encode_cell_property(cell.position, CELL_PROPERTIES.PLANT_TYPE_ID, cell.plant_type_id)
	encode_cell_property(cell.position, CELL_PROPERTIES.PLANT_GROWTH, cell.plant_growth)
	encode_cell_property(cell.position, CELL_PROPERTIES.PLANT_TURNS_ALIVE, cell.plant_turns_alive)

func encode_cell_property(position: Vector2i, property: CELL_PROPERTIES, value: int):
	terrain_array.encode_s8(position_to_cell_index(position) + property, value)

# ---DECODING---
func decode_cell(position: Vector2i) -> Cell:
	var hydration = decode_cell_property(position, CELL_PROPERTIES.HYDRATION)
	var sunlight = decode_cell_property(position, CELL_PROPERTIES.SUNLIGHT)
	var plant_type_id = decode_cell_property(position, CELL_PROPERTIES.PLANT_TYPE_ID)
	var plant_growth = decode_cell_property(position, CELL_PROPERTIES.PLANT_GROWTH)
	var plant_turns_alive = decode_cell_property(position, CELL_PROPERTIES.PLANT_TURNS_ALIVE)
	return Cell.new(position, hydration, sunlight, plant_type_id, plant_growth, plant_turns_alive)

func decode_cell_property(position: Vector2i, property: CELL_PROPERTIES) -> int:
	return terrain_array.decode_s8(position_to_cell_index(position) + property)

# ---Utilities---
func position_to_cell_index(position: Vector2i) -> int:
	return (position.y * MASTER_GRID_SIZE + position.x) * CELL_PROPERTIES.size()

#+------------------------------------------------------------------------------+
#|                                  UTILITIES                                   |
#+------------------------------------------------------------------------------+
func pixel_to_grid(pixel_position: Vector2i) -> Vector2i:
	return terrain_renderer.local_to_map(pixel_position)
	
func grid_to_pixel(pixel_position: Vector2i) -> Vector2i:
	return terrain_renderer.map_to_local(pixel_position)
