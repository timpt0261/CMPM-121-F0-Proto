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

var plant_type_id: int
var plant_growth: int
var plant_turns_alive: int
var plant_visual_phase: int

var JUVENILE
var ADULT
var DEAD
var POINTS
var MAX_TURNS


func _init(
	position: Vector2i,
	hydration = -1,
	sunlight = -1,
	plant_type_id = -1,
	plant_growth = -1,
	plant_turns_alive = -1,
	plant_template = null
):
	self.position = position
	var rnd = RandomNumberGenerator.new()
	if hydration < 0:
		hydration = rnd.randi_range(0, 100)
	if sunlight < 0:
		sunlight = rnd.randi_range(0, 100)
	set_sunlight(hydration)
	set_hydration(sunlight)

	set_plant(plant_type_id, plant_growth, plant_turns_alive, plant_template)


func update_properties(adjacent_plants: Array):
	var rnd = RandomNumberGenerator.new()
	set_sunlight(rnd.randi_range(0, 100))
	set_hydration(clampi(hydration + rnd.randi_range(-15, 15), 0, 100))
	if plant_type_id >= 0:
		set_plant_turns_alive(plant_turns_alive + 1)
		set_plant_growth(plant_growth + get_plant_turn_growth(adjacent_plants))


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


func set_plant(plant_type_id, plant_growth, plant_turns_alive, plant_template):
	self.plant_type_id = plant_type_id
	if plant_type_id < 0:
		return

	JUVENILE = plant_template.get("juvenile")
	ADULT = plant_template.get("adult")
	DEAD = plant_template.get("dead")
	POINTS = plant_template.get("points")
	MAX_TURNS = plant_template.get("max_turns")

	set_plant_growth(plant_growth)
	set_plant_turns_alive(plant_turns_alive)


func set_plant_growth(growth: int):
	plant_growth = growth
	if plant_growth >= DEAD:
		clear_plant()
		return
	if plant_growth >= JUVENILE && plant_growth < ADULT:
		plant_visual_phase = 1
	elif plant_growth >= ADULT && plant_growth < DEAD:
		plant_visual_phase = 2


func set_plant_turns_alive(turns_alive: int):
	plant_turns_alive = turns_alive
	if plant_turns_alive > MAX_TURNS:
		clear_plant()


func clear_plant():
	plant_type_id = -1
	plant_growth = -1
	plant_turns_alive = -1
	plant_visual_phase = -1


func get_plant_turn_growth(adjacent_plants: Array):
	var water_ratio = hydration / 100.0
	var sun_ratio = sunlight / 100.0

	var adjacent_plant_bonus = 0
	for plant in adjacent_plants:
		adjacent_plant_bonus += 1

	return sun_ratio + water_ratio * adjacent_plant_bonus
