class_name TerrainRenderer extends TileMap

@onready var terrain_map = $"../../TerrainMap"

enum layers_IDs {
	GRASS = 0,
	HIGHLIGHT = 1,
	CURSOR = 2,
}

const CELL_PIXEL_SIZE = 16
const PLANT_SPRITES_SIZE = 16

var plant_objs: Dictionary


# Called when the node enters the scene tree for the first time.
func _ready():
	terrain_map.terrain_updated.connect(render_terrain.bind())
	plant_objs = {}


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
	var plant_obj = get_plant_obj(cell)
	if plant_obj != null && cell.plant == null:
		plant_obj.queue_free()
		plant_objs.erase(cell.position)
		plant_obj = null
	if plant_obj == null:
		return
	var atlas_tex = AtlasTexture.new();
	atlas_tex.atlas = PlantTemplates.get_templates()[cell.get_plant_id()].texture
	atlas_tex.region = Rect2(cell.plant.get_visual_phase() * PLANT_SPRITES_SIZE, 0, PLANT_SPRITES_SIZE, PLANT_SPRITES_SIZE);
	plant_obj.texture = atlas_tex;

func get_plant_obj(cell: Cell) -> Sprite2D:
	if plant_objs.has(cell.position):
		return plant_objs[cell.position]
	elif cell.get_plant_id() >= 0:
		var plant_obj = new_plant_obj(cell)
		plant_objs[cell.position] = plant_obj
		return plant_obj
	else:
		return null

func new_plant_obj(cell: Cell) -> Sprite2D:
	var plant_obj = Sprite2D.new()
	plant_obj.name = "Plant: " + str(cell.position)
	plant_obj.position = map_to_local(cell.position)
	add_child(plant_obj)
	return plant_obj


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
