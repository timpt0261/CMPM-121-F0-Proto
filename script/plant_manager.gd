extends Node2D

@onready var plant = preload("res://scene/Plant.tscn");
@onready var terrain_map = $"../../TerrainMap";

var plantDict = Dictionary();

signal harvested_plant;

func plant_plant(pos):
	var p = plant.instantiate();
	p.global_position = terrain_map.map_to_local(pos);
	plantDict[str(pos)] = p;
	add_child(p);
	
func update_plants():
	for key in plantDict:
		var current_plant = plantDict.get(key);
		if (current_plant.update_age() == false):
			erase_plant(key);

func harvest_plant(pos):
	# Already checked to see if plant exists
	var current_plant = plantDict.get(str(pos));
	print(pos);
	if (current_plant.age >= current_plant.ADULT):
		harvested_plant.emit();
	erase_plant(pos);
	
func erase_plant(pos):
	var key = str(pos);
	if !is_plant_at_pos(pos): return;
	plantDict.get(key).queue_free();
	plantDict.erase(key);

func is_plant_at_pos(pos):
	var p = plantDict.get(str(pos))
	if (p): return true;
	else: return false;
