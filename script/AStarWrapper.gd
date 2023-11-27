class_name AStarWrapper extends Node
var a_star_grid: AStarGrid2D
const CELL_SIZE = 16;
const GRID_SPACE = Rect2i(0, 0, CELL_SIZE, CELL_SIZE)

# Called when the node enters the scene tree for the first time.
func _init():
	a_star_grid = AStarGrid2D.new()
	a_star_grid.region = GRID_SPACE
	a_star_grid.cell_size = Vector2(CELL_SIZE,CELL_SIZE);
	a_star_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER;
	a_star_grid.update();

func get_id_path(source: Vector2i, target: Vector2i):
	return a_star_grid.get_id_path(source, target);
