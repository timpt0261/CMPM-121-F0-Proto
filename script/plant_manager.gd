class_name PlantManager extends Node2D

@onready var plant = preload("res://scene/Plant.tscn");
@onready var terrain_map = $"../../TerrainMap";

var plant_harvested_count = 0
const MAX_FLOWERS_TO_HARVEST = 5


var plantDict = Dictionary();

signal harvested_plant;

func plant_plant(pos):
	if (is_plant_at_pos(pos)): return
	var p = plant.instantiate();
	p.global_position = terrain_map.grid_to_pixel(pos);
	plantDict[pos] = p;
	add_child(p);
	
func update_plants():
	if plantDict.is_empty(): return;
	for key in plantDict:
		var current_plant = plantDict.get(key);
		update_adjacent_plant_bonus(key);
		if (current_plant.update_age() == false):
			erase_plant(key);

func harvest_plant(pos):
	if !is_plant_at_pos(pos): return false;
	var current_plant = plantDict.get(pos);
	
	if (current_plant.growth >= current_plant.ADULT):
		plant_harvested_count += 1
		if plant_harvested_count >= MAX_FLOWERS_TO_HARVEST:
			game_over();
		harvested_plant.emit();
	erase_plant(pos);
	return true;
	
func erase_plant(pos):
	if !is_plant_at_pos(pos): return;
	plantDict.get(pos).queue_free();
	plantDict.erase(pos);

func is_plant_at_pos(pos):
	var p = plantDict.get(pos);
	if (p): return true;
	else: return false;
	
func update_adjacent_plant_bonus(pos):
	var current_plant = plantDict.get(pos);
	var bonus: int = 0;
	for i in range(-1,1):
		for j in range (-1, 1):
			if (i == j): continue;
			if is_plant_at_pos(pos + Vector2i(i,j)):
				bonus += 1;
				
	current_plant.adjacent_plant_bonus = bonus;
func get_plant_harvested_amount():
	return plant_harvested_count;
	
func game_over():
	# Show the game over screen or perform any other game over actions
	var game_over_screen = preload("res://scene/game_over.tscn").instantiate() # Adjust the path
	get_tree().current_scene.add_child(game_over_screen)
	game_over_screen.show()
