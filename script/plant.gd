class_name Plant extends Node2D

@onready var terrain_map = $"../../../TerrainMap";
var plant_type_id
var growth = 0;
var turns_alive = 0;

var JUVENILE;
var ADULT;
var DEAD;

const REGION_SIZE = 16;
const OVERFLOWING = 80;
const TOO_SUNNY = 80;

var adjacent_plant_bonus: int = 0;

var plant_recipe;
var sprite;
var points;
var max_turns;
var plant_list;
	
func _ready():
	sprite = $"Sprite";
	plant_list = get_plant_list("res://data/plants.json");
	initialize_plant();
	set_phase(0);


func initialize_plant():
	var rnd = RandomNumberGenerator.new();
	plant_type_id = rnd.randi_range(0, plant_list.size() - 1)
	plant_recipe = plant_list[plant_type_id];
	points = plant_recipe.get("points");
	JUVENILE = plant_recipe.get("juvenile");
	ADULT = plant_recipe.get("adult");
	DEAD = plant_recipe.get("dead");
	max_turns = plant_recipe.get("max_turns");
	
func set_phase(phase):
	var atlas_tex = AtlasTexture.new();
	atlas_tex.atlas = load(plant_recipe.get("sprite"));
	
	
	atlas_tex.region = Rect2(phase * REGION_SIZE, 0, REGION_SIZE, REGION_SIZE);
	sprite.texture = atlas_tex;

func update_age():
	var terrain_pos = terrain_map.pixel_to_grid(global_position);
	var grass_underneath = terrain_map.get_grass(terrain_pos.x, terrain_pos.y);
	var water_ratio = (float)(grass_underneath.get_hydration()) / 100;
	var sun_ratio = (float)(grass_underneath.get_sunlight()) / 100;
	
	
	growth += (sun_ratio) + (water_ratio) * adjacent_plant_bonus;


	if (growth >= JUVENILE && growth < ADULT):
		set_phase(1);
	elif(growth >= ADULT && growth < DEAD):
		set_phase(2);
	turns_alive += 1;
	if (growth >= DEAD || turns_alive > max_turns):
		return false;
		
	return true;

func get_plant_list (file_path):
	var file = FileAccess.open(file_path, FileAccess.READ);
	var plant_as_text = file.get_as_text();
	var plant_as_array = JSON.parse_string(plant_as_text);
	return plant_as_array;
