class_name Grass extends Node

const ABOVE_IS_SUNNY = 49;
const BELOW_IS_WET = 33;
const ABOVE_IS_DRY = 66;

var x;
var y;

signal grass_changed;
signal sun_given;
signal sun_taken;

var sunlight_amt: int = 0;
var water_amt: int = 0;
var tile_type: grass_type

var sunny: bool = false;

enum grass_type {
	WET_GRASS = 0,
	NORMAL_GRASS = 1,
	DRY_GRASS = 2
};

func _init(_x,_y):
	var rnd = RandomNumberGenerator.new();
	water_amt = rnd.randi_range(0, 100);
	randomize_tile_properties();
	x = _x;
	y = _y;


func randomize_tile_properties():
	var rnd = RandomNumberGenerator.new();
	water_amt += rnd.randi_range(-15, 15);
	water_amt = clampi(water_amt, 0, 100);
	sunlight_amt = rnd.randi_range(0,100);
	set_sunlight(sunlight_amt);
	set_wetness();
	
	
func set_wetness():
	
	@warning_ignore("integer_division")
	var sun_affecting_water = sunlight_amt/20;
	water_amt -= sun_affecting_water;
	water_amt = clampi(water_amt, 0, 100);
	
	if (water_amt < BELOW_IS_WET):
		set_tile_type(grass_type.WET_GRASS);
	elif (water_amt >= BELOW_IS_WET && water_amt <= ABOVE_IS_DRY):
		set_tile_type(grass_type.NORMAL_GRASS)
	elif (water_amt > ABOVE_IS_DRY):	
		set_tile_type(grass_type.DRY_GRASS)

func get_wetness():
	return tile_type;
	
func set_sunlight(sun):
	
	sunlight_amt = sun;
	if (sunlight_amt > ABOVE_IS_SUNNY): 
		sunny = true;
		sun_given.emit(self);
	else: 
		sunny = false;
		sun_taken.emit(self);

func get_sunlight():
	return sunny;
	
func set_tile_type(type: grass_type):
	if (tile_type == type): 
		return;
	tile_type = type;
	grass_changed.emit(self);

	
