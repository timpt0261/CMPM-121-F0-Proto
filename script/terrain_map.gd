class_name TerrainMap extends Node2D

signal terrain_updated
signal increment_score

@onready var terrain_renderer = $"TerrainRenderer"

const MASTER_GRID_SIZE = 16

var farm_grid: FarmGrid


func _ready():
	($"../Labels/TurnCount").new_turn_signal.connect(update_grid.bind())

	set_farm_grid(FarmGrid.new(MASTER_GRID_SIZE, MASTER_GRID_SIZE))


#+------------------------------------------------------------------------------+
#|                              Terrain Management                              |
#+------------------------------------------------------------------------------+
func set_farm_grid(farm_grid: FarmGrid):
	self.farm_grid = farm_grid
	terrain_updated.emit()


func update_grid():
	for cell in farm_grid:
		cell.update_properties(get_adjacent_plant_ids(cell.position))
		farm_grid.encode_cell(cell)
	terrain_updated.emit()


func get_grass(x, y) -> Cell:
	if x < 0 || x >= MASTER_GRID_SIZE || y < 0 || y >= MASTER_GRID_SIZE:
		return null
	else:
		return farm_grid.decode_cell(Vector2i(x, y))


#+------------------------------------------------------------------------------+
#|                                    Plants                                    |
#+------------------------------------------------------------------------------+
func plant_at(plant_position: Vector2i, plant_type_id: int) -> bool:
	var cell = farm_grid.decode_cell(plant_position)
	if cell.plant_type_id >= 0:
		return false
	cell.set_plant(plant_type_id, 0, 0, farm_grid.plant_template_list[plant_type_id])
	farm_grid.encode_cell(cell)
	return true


func harvest_at(plant_position: Vector2i) -> bool:
	var cell = farm_grid.decode_cell(plant_position)
	if cell.plant_type_id < 0 || cell.plant_visual_phase < 2:
		return false
	increment_score.emit(cell.POINTS)
	cell.clear_plant()
	farm_grid.encode_cell(cell)
	return true


func get_adjacent_plant_ids(plant_position: Vector2i) -> Array:
	var adjacent_plants = []
	for cell in farm_grid.get_adjacent_cells(plant_position):
		adjacent_plants.append(cell.plant_type_id)
	return adjacent_plants


#+------------------------------------------------------------------------------+
#|                                  UTILITIES                                   |
#+------------------------------------------------------------------------------+
func pixel_to_grid(pixel_position: Vector2i) -> Vector2i:
	return terrain_renderer.pixel_to_grid(pixel_position)


func grid_to_pixel(pixel_position: Vector2i) -> Vector2i:
	return terrain_renderer.grid_to_pixel(pixel_position)


func snap_to_grid(pixel_position: Vector2i) -> Vector2i:
	return terrain_renderer.snap_to_grid(pixel_position)
