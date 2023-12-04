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
	PlANT_TIME_ALIVE = 4
}

func _ready():
	($"../Labels/TurnCount").next_turn_signal.connect(update_grid.bind())
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
#|                       Byte Array encoding and decoding                       |
#+------------------------------------------------------------------------------+

# ---ENCODING---
func encode_cell(cell: Cell):
	encode_cell_property(cell.position, CELL_PROPERTIES.HYDRATION, cell.get_hydration())
	encode_cell_property(cell.position, CELL_PROPERTIES.SUNLIGHT, cell.get_sunlight())

func encode_cell_property(position: Vector2i, property: CELL_PROPERTIES, value: int):
	terrain_array.encode_s8(position_to_cell_index(position) + property, value)

# ---DECODING---
func decode_cell(position: Vector2i) -> Cell:
	return Cell.new(position, decode_cell_property(position, CELL_PROPERTIES.HYDRATION), decode_cell_property(position, CELL_PROPERTIES.SUNLIGHT))

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
