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
	for key in plantDict:
		print(plantDict.get(key).age);
		plantDict.get(key).update_age();
		
