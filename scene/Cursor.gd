extends Node2D

@onready var tile_map = $"../../TileMap"
@onready var terrainMap = preload("res://scene/TerrainMap.gd");
var mapFromMouse = Vector2i(0,0);

func _input(event):
	set_new_cursor_location();

func set_new_cursor_location():
	var newPos = tile_map.local_to_map(get_global_mouse_position());
	if (mapFromMouse != newPos):
		tile_map.erase_cell(terrainMap.layersIDs.CURSOR, mapFromMouse);
		mapFromMouse = newPos;
	tile_map.set_cell(2, mapFromMouse, 2, Vector2i(0,0));
