extends Label


signal next_turn_signal;
var turn_number = 0;
@onready var plant_manager = $"../../TerrainMap/Plants";
@onready var terrain_map = $"../../TerrainMap/";

func next_turn():
	turn_number += 1; 
	text = "Turn #: " +  str(turn_number);
	terrain_map.update_grass();
	plant_manager.update_plants();
	
