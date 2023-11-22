extends Label


signal next_turn_signal;
var turn_number = 0;
@onready var plant_manager = $"../../TileMap/Plants";
@onready var terrainMap = $"../../TileMap";

func next_turn():
	turn_number += 1;
	text = "Turn #: " +  str(turn_number);
	
	
	terrainMap.update_grass();
	plant_manager.update_plants();
	
	
