extends Node2D

@onready var plant = preload("res://scene/plant.tscn");

var plantDict = Dictionary();

func plant_plant(pos):
	var p = plant.instantiate();
	print(p);
	p.global_position = pos;
	plantDict[str(pos)] = p;
	add_child(p);
	
func get_plant_at_pos(pos):
	var p = plantDict.get(str(pos))
	return p;
	
func update_plants():
	print(plantDict.size());
	for key in plantDict:
		var current_plant = plantDict.get(key);
		if current_plant.age >= 16:
			current_plant.queue_free();
			plantDict.erase(key);
		else:
			current_plant.update_age();
		
