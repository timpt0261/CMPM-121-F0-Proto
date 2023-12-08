class_name TerrainRenderer extends TileMap

@onready var terrain_map = $"../../TerrainMap"

enum layers_IDs {
	GRASS = 0,
	HIGHLIGHT = 1,
	CURSOR = 2,
}

const CELL_PIXEL_SIZE = 16
const PLANT_SPRITES_SIZE = 16

var plant_sprite_dict: Dictionary


# Called when the node enters the scene tree for the first time.
func _ready():
	terrain_map.terrain_updated.connect(render_terrain.bind())
	plant_sprite_dict = {}


func render_terrain():
	for cell in terrain_map.farm_grid:
		render_cell(cell)


func render_cell(cell: Cell):
	set_cell(layers_IDs.GRASS, cell.position, layers_IDs.GRASS, Vector2i(cell.hydration_stage, 0))
	if cell.get_is_sunny():
		set_cell(layers_IDs.HIGHLIGHT, cell.position, layers_IDs.HIGHLIGHT, Vector2i(0, 0))
	else:
		erase_cell(layers_IDs.HIGHLIGHT, cell.position)
	update_plant_sprite(cell)


func update_plant_sprite(cell: Cell):
	var plant_sprite = get_plant_sprite(cell)
	if plant_sprite != null && cell.plant_type_id < 0:
		plant_sprite.queue_free()
		plant_sprite_dict.erase(cell.position)
		plant_sprite = null
	if plant_sprite == null:
		return
	var atlas_tex = AtlasTexture.new()
	atlas_tex.atlas = load(
		terrain_map.farm_grid.plant_template_list[cell.plant_type_id].get("sprite")
	)
	atlas_tex.region = Rect2(
		cell.plant_visual_phase * PLANT_SPRITES_SIZE, 0, PLANT_SPRITES_SIZE, PLANT_SPRITES_SIZE
	)
	plant_sprite.texture = atlas_tex


func get_plant_sprite(cell: Cell) -> Sprite2D:
	if plant_sprite_dict.has(cell.position):
		return plant_sprite_dict[cell.position]
	elif cell.plant_type_id >= 0:
		var plant_sprite = new_plant_sprite(cell)
		plant_sprite_dict[cell.position] = plant_sprite
		return plant_sprite
	else:
		return null


func new_plant_sprite(cell: Cell) -> Sprite2D:
	var sprite = Sprite2D.new()
	sprite.name = "Plant: " + str(cell.position)
	sprite.position = map_to_local(cell.position)
	add_child(sprite)
	return sprite


func get_relative_pixel_position(global_pixel_position: Vector2i) -> Vector2i:
	return global_pixel_position - (global_position as Vector2i)


func pixel_to_grid(pixel_position: Vector2i) -> Vector2i:
	return get_relative_pixel_position(pixel_position) / CELL_PIXEL_SIZE


func grid_to_pixel(grid_position: Vector2i) -> Vector2i:
	return grid_position * CELL_PIXEL_SIZE + (global_position as Vector2i)


func snap_to_grid(pixel_position: Vector2i) -> Vector2i:
	return grid_to_pixel(pixel_to_grid(pixel_position))


func pixel_in_bounds(pixel_pos: Vector2i) -> bool:
	var pixel_width = terrain_map.farm_grid.width * PLANT_SPRITES_SIZE
	var pixel_height = terrain_map.farm_grid.height * PLANT_SPRITES_SIZE
	var relative = get_relative_pixel_position(pixel_pos)
	return (
		relative.x >= 0 && relative.x < pixel_width && relative.y >= 0 && relative.y < pixel_height
	)
