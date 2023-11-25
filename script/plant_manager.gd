extends Node2D

@onready var plant = preload("res://scene/Plant.tscn");
@onready var terrain_map = $"../../TerrainMap";

var plantDict = Dictionary();

signal harvested_plant;

func plant_plant(pos):
	var p = plant.instantiate();
	p.global_position = terrain_map.map_to_local(pos);
	plantDict[pos] = p;
	add_child(p);
	
func update_plants():
	for key in plantDict:
		var current_plant = plantDict.get(key);
		update_adjacent_plant_bonus(key);
		current_plant.turns_alive += 1;
		if (current_plant.update_age() == false):
			erase_plant(key);

func harvest_plant(pos):
	# Already checked to see if plant exists
	var current_plant = plantDict.get(pos);
	if (current_plant.growth >= current_plant.ADULT):
		harvested_plant.emit();
	erase_plant(pos);
	
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
		
