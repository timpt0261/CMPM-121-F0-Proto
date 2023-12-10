class_name FarmGridArray

enum CELL_PROPERTIES {
	HYDRATION = 0, SUNLIGHT = 1, PLANT_TYPE_ID = 2, PLANT_GROWTH = 3, PLANT_TURNS_ALIVE = 4
}

var plant_template_list

var byte_array: PackedByteArray

var width: int
var height: int
var iter_current: int
var iter_end: int
const iter_start = 0
const iter_increment = 1


#+------------------------------------------------------------------------------+
#|                                Initialization                                |
#+------------------------------------------------------------------------------+
func _init(width: int, height: int, byte_array = null):
	self.width = width
	self.height = height

	iter_current = iter_start
	iter_end = width * height

	plant_template_list = get_plant_list("res://data/plants.json")

	if byte_array == null:
		self.byte_array = PackedByteArray()
		self.byte_array.resize(width * height * CELL_PROPERTIES.size())
		generate_initial_cells()
	else:
		self.byte_array = byte_array


func generate_initial_cells():
	for y in height:
		for x in width:
			encode_cell(Cell.new(Vector2i(x, y)))


#+------------------------------------------------------------------------------+
#|                                   Iteration                                  |
#+------------------------------------------------------------------------------+
func should_continue():
	return iter_current < iter_end


func _iter_init(arg):
	iter_current = iter_start
	return should_continue()


func _iter_next(arg):
	iter_current += iter_increment
	return should_continue()


func _iter_get(arg):
	var iter_position = Vector2i(iter_current / width, iter_current % width)
	return decode_cell(iter_position)


#+------------------------------------------------------------------------------+
#|                              General Operations                              |
#+------------------------------------------------------------------------------+
func get_adjacent_cells(cell_position: Vector2i) -> Array:
	var adjacent_cells = []
	for j in range(-1, 1):
		for i in range(-1, 1):
			var adjacent_pos = cell_position + Vector2i(i, j)
			var adjacent_index = adjacent_pos.y * width + adjacent_pos.x
			if (
				adjacent_pos == cell_position
				|| adjacent_index < 0
				|| adjacent_index >= width * height
			):
				continue
			adjacent_cells.append(decode_cell(adjacent_pos))
	return adjacent_cells


static func array_size_of(width: int, height: int):
	return width * height * CELL_PROPERTIES.size()


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
	byte_array.encode_s8(position_to_cell_index(position) + property, value)


# ---DECODING---
func decode_cell(position: Vector2i) -> Cell:
	var hydration = decode_cell_property(position, CELL_PROPERTIES.HYDRATION)
	var sunlight = decode_cell_property(position, CELL_PROPERTIES.SUNLIGHT)
	var plant_type_id = decode_cell_property(position, CELL_PROPERTIES.PLANT_TYPE_ID)
	var plant_growth = decode_cell_property(position, CELL_PROPERTIES.PLANT_GROWTH)
	var plant_turns_alive = decode_cell_property(position, CELL_PROPERTIES.PLANT_TURNS_ALIVE)
	return Cell.new(
		position,
		hydration,
		sunlight,
		plant_type_id,
		plant_growth,
		plant_turns_alive,
		plant_template_list[plant_type_id]
	)


func decode_cell_property(position: Vector2i, property: CELL_PROPERTIES) -> int:
	return byte_array.decode_s8(position_to_cell_index(position) + property)


# ---Utilities---
func position_to_cell_index(position: Vector2i) -> int:
	return (position.y * width + position.x) * CELL_PROPERTIES.size()


func get_plant_list(file_path: String) -> Array:
	var file = FileAccess.open(file_path, FileAccess.READ)
	return JSON.parse_string(file.get_as_text())
