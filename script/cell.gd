class_name Cell

const ABOVE_IS_SUNNY = 49
const BELOW_IS_WET = 33
const ABOVE_IS_DRY = 66

enum hydration_stages { WET_GRASS = 0, NORMAL_GRASS = 1, DRY_GRASS = 2 }

var position: Vector2i

var sunlight: int = 0
var hydration: int = 0

var hydration_stage: hydration_stages
var is_sunny: bool = false

var plant: Plant

func _init(position: Vector2i, hydration = -1, sunlight = -1, plant_type_id = -1, plant_growth = -1, plant_turns_alive = -1):
	self.position = position
	var rnd = RandomNumberGenerator.new()
	if hydration < 0:
		hydration = rnd.randi_range(0, 100)
	if sunlight < 0:
		sunlight = rnd.randi_range(0, 100)
	set_sunlight(hydration);
	set_hydration(sunlight);
	
	set_plant(plant_type_id, plant_growth, plant_turns_alive)

func update_properties(adjacent_plants: Array[int]):
	var rnd = RandomNumberGenerator.new();
	set_sunlight(rnd.randi_range(0,100));
	set_hydration(clampi(hydration + rnd.randi_range(-15, 15), 0, 100));
	if(plant != null):
		var growth_context = GrowthContext.new(hydration, sunlight, plant, adjacent_plants)
		PlantTemplates.get_templates()[plant.id].grow.call(growth_context)
		plant.turns_alive += 1
		if(plant.is_dead()):
			clear_plant()


func set_hydration(new_hydration: int):
	hydration = new_hydration
	@warning_ignore("integer_division")
	var sun_affecting_water = sunlight / 20
	hydration = clampi(hydration - sun_affecting_water, 0, 100)

	if hydration < BELOW_IS_WET:
		hydration_stage = hydration_stages.WET_GRASS
	elif hydration >= BELOW_IS_WET && hydration <= ABOVE_IS_DRY:
		hydration_stage = hydration_stages.NORMAL_GRASS
	elif hydration > ABOVE_IS_DRY:
		hydration_stage = hydration_stages.DRY_GRASS


func set_sunlight(new_sunlight: int):
	sunlight = new_sunlight
	is_sunny = sunlight > ABOVE_IS_SUNNY


func get_hydration():
	return hydration


func get_hydration_stage():
	return hydration_stage


func get_sunlight():
	return sunlight


func get_is_sunny():
	return is_sunny


func set_tile_type(type: hydration_stages):
	hydration_stage = type


func set_plant(id, growth, turns_alive):
	if(id < 0):
		plant = null
	else:
		plant = Plant.new(id, growth, turns_alive)

func get_plant_id():
	if(plant == null):
		return -1
	else:
		return plant.id
		
func get_plant_growth():
	if(plant == null):
		return -1
	else:
		return plant.growth
		
func get_plant_turns_alive():
	if(plant == null):
		return -1
	else:
		return plant.turns_alive


func clear_plant():
	plant = null
