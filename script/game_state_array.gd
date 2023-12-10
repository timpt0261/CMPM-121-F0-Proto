class_name GameStateArray

enum DataIndices {
	PLAYER_POSITION_X = 0,
	PLAYER_POSITION_Y = 1,
	TURN_COUNT = 2,
	SCORE_COUNT = 3,
	FARM_GRID_WIDTH = 4,
	FARM_GRID_HEIGHT = 5
}

var byte_array: PackedByteArray


func _init():
	byte_array = PackedByteArray()
	byte_array.resize(DataIndices.size())


static func from_byte_array(byte_array: PackedByteArray) -> GameStateArray:
	var game_state_array = GameStateArray.new()
	game_state_array.byte_array = byte_array
	return game_state_array


func get_array_size() -> int:
	return byte_array.size()


static func array_size_of(width: int, height: int):
	return DataIndices.size() + FarmGridArray.array_size_of(width, height)


func set_int_data(data_type: DataIndices, data: int):
	byte_array.encode_s8(data_type, data)


func set_player_position(player_position: Vector2i):
	set_int_data(DataIndices.PLAYER_POSITION_X, player_position.x)
	set_int_data(DataIndices.PLAYER_POSITION_Y, player_position.y)


func set_turn_count(turn_count: int):
	set_int_data(DataIndices.TURN_COUNT, turn_count)


func set_score_count(score_count: int):
	set_int_data(DataIndices.SCORE_COUNT, score_count)


func set_farm_grid(farm_grid: FarmGridArray):
	set_int_data(DataIndices.FARM_GRID_WIDTH, farm_grid.width)
	set_int_data(DataIndices.FARM_GRID_HEIGHT, farm_grid.height)

	byte_array = byte_array.slice(0, DataIndices.size())
	byte_array.append_array(farm_grid.byte_array)


func get_int_data(data_type: DataIndices) -> int:
	return byte_array.decode_s8(data_type)


func get_player_position() -> Vector2i:
	var x = get_int_data(DataIndices.PLAYER_POSITION_X)
	var y = get_int_data(DataIndices.PLAYER_POSITION_Y)
	return Vector2i(x, y)


func get_turn_count() -> int:
	return get_int_data(DataIndices.TURN_COUNT)


func get_score_count() -> int:
	return get_int_data(DataIndices.SCORE_COUNT)


func get_farm_grid() -> FarmGridArray:
	var farm_grid_array = byte_array.slice(DataIndices.size())
	var farm_grid_width = get_int_data(DataIndices.FARM_GRID_WIDTH)
	var farm_grid_height = get_int_data(DataIndices.FARM_GRID_HEIGHT)
	return FarmGridArray.new(farm_grid_width, farm_grid_height, farm_grid_array)
