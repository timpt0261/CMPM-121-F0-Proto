class_name TerrainMap extends Node2D

signal terrain_updated

@onready var plant_manager = $"../TerrainRenderer/Plants"

const MASTER_GRID_SIZE = 16;

var terrain_array: PackedByteArray
enum CELL_PROPERTIES {
	HYDRATION = 0,
	SUNLIGHT = 8,
	PLANT_TYPE_ID = 9,
	PLANT_GROWTH = 10
}

func _ready():
	for x in MASTER_GRID_SIZE:
		for y in MASTER_GRID_SIZE:
			encode_cell(Cell.new(Vector2i(x, y)))
	terrain_updated.emit()
	
func get_grass(x,y) -> Cell:
	if x < 0 || x >= MASTER_GRID_SIZE || y < 0 || y >= MASTER_GRID_SIZE:
		return null
	else:
		return decode_cell(Vector2i(x, y));

func update_grass():
	for x in MASTER_GRID_SIZE:
		for y in MASTER_GRID_SIZE:
			var cell_instance = decode_cell(Vector2i(x, y))
			cell_instance.randomize_tile_properties()
			encode_cell(cell_instance)
	terrain_updated.emit()
	
func encode_cell(cell: Cell):
	encode_cell_property(cell.position, CELL_PROPERTIES.HYDRATION, cell.get_hydration())
	encode_cell_property(cell.position, CELL_PROPERTIES.SUNLIGHT, cell.get_sunlight())
	
func encode_cell_property(position: Vector2i, property: CELL_PROPERTIES, value: int):
	var cell_index = position.y * MASTER_GRID_SIZE + position.x
	terrain_array.encode_s8(cell_index + property, value)
	
func decode_cell(position: Vector2i) -> Cell:
	return Cell.new(position, decode_cell_property(position, CELL_PROPERTIES.HYDRATION), decode_cell_property(position, CELL_PROPERTIES.SUNLIGHT))
	
func decode_cell_property(position: Vector2i, property: CELL_PROPERTIES) -> int:
	var cell_index = position.y * MASTER_GRID_SIZE + position.x
	return terrain_array.decode_s8(cell_index + property)
