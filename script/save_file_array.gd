class_name SaveFileArray

enum DataIndices {
	CURRENT_SNAPSHOT = 0,
	SNAPSHOT_SIZE = 1,
	SNAPSHOTS_START = 9
}

var byte_array: PackedByteArray

func _init():
	byte_array = PackedByteArray()
	byte_array.resize(DataIndices.SNAPSHOTS_START)

static func from_byte_array(byte_array: PackedByteArray) -> SaveFileArray:
	var save_file_array = SaveFileArray.new()
	save_file_array.byte_array = byte_array
	return save_file_array

func set_current_snapshot(current_snapshot: int):
	byte_array.encode_s8(DataIndices.CURRENT_SNAPSHOT, current_snapshot)

func set_snapshot_size(snapshot_size: int):
	byte_array.encode_s64(DataIndices.SNAPSHOT_SIZE, snapshot_size)

func add_snapshot(snapshot: GameStateArray):
	byte_array.append_array(snapshot.byte_array)

func get_current_snapshot() -> int:
	return byte_array.decode_s8(DataIndices.CURRENT_SNAPSHOT)

func get_snapshot_size() -> int:
	return byte_array.decode_s64(DataIndices.SNAPSHOT_SIZE)

func get_snapshots() -> Array[GameStateArray]:
	var snapshots: Array[GameStateArray] = []
	
	var snapshot_size = get_snapshot_size()
	var loop_bound = byte_array.size() - snapshot_size
	var snapshot_index = DataIndices.SNAPSHOTS_START
	while snapshot_index <= loop_bound:
		snapshots.append(GameStateArray.from_byte_array(byte_array.slice(snapshot_index, snapshot_index + snapshot_size)))
		snapshot_index += snapshot_size
	
	return snapshots
