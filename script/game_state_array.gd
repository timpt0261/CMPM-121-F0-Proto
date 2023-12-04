class_name game_state_array

const PLAYER_POSITION_INDEX = 0
const TURN_COUNT_INDEX = 12
const SCORE_INDEX = 20
const CELLS_START = 28

const SIZE_OF_VECTOR2I = 12;
const SIZE_OF_INT = 8;

var byte_array: PackedByteArray
var grid_side_length: int

func _init(side_length):
	byte_array = PackedByteArray()
	grid_side_length = side_length
	
func clear():
	byte_array.clear()
	
func duplicate():
	return byte_array.duplicate()
	
func set_byte_array(new_byte_array: PackedByteArray):
	byte_array = new_byte_array
	
func as_byte_array() -> PackedByteArray:
	return byte_array
	
func push(data):
	var data_bytes = var_to_bytes(data)
	byte_array.append_array(data_bytes)
	
func get_player_position() -> Vector2i:
	var player_position_bytes = byte_array.slice(PLAYER_POSITION_INDEX, PLAYER_POSITION_INDEX + SIZE_OF_VECTOR2I)
	return bytes_to_var(player_position_bytes) as Vector2i
	
func get_turn_count() -> int:
	var turn_count_bytes = byte_array.slice(TURN_COUNT_INDEX, TURN_COUNT_INDEX + SIZE_OF_INT)
	return bytes_to_var(turn_count_bytes) as int
	
func get_score() -> int:
	var score_bytes = byte_array.slice(SCORE_INDEX, SCORE_INDEX + SIZE_OF_INT)
	return bytes_to_var(score_bytes) as int
	
func get_hydration(pos: Vector2i) -> int:
	var index = pos.y * grid_side_length + pos.x + CELLS_START
	var hydration_bytes = byte_array.slice(index, index + SIZE_OF_INT)
	return bytes_to_var(hydration_bytes) as int
	
func get_sunlight(pos: Vector2i) -> int:
	var index = pos.y * grid_side_length + pos.x + CELLS_START + SIZE_OF_INT
	var sunlight_bytes = byte_array.slice(index, index + SIZE_OF_INT)
	return bytes_to_var(sunlight_bytes) as int
	
func get_plant_id(pos: Vector2i) -> int:
	var index = pos.y * grid_side_length + pos.x + CELLS_START + SIZE_OF_INT * 2
	var plant_id_bytes = byte_array.slice(index, index + SIZE_OF_INT)
	return bytes_to_var(plant_id_bytes) as int
	
func get_growth(pos: Vector2i) -> int:
	var index = pos.y * grid_side_length + pos.x + CELLS_START + SIZE_OF_INT * 3
	var growth_bytes = byte_array.slice(index, index + SIZE_OF_INT)
	return bytes_to_var(growth_bytes) as int
