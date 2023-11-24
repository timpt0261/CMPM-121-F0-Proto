extends Node2D

@onready var terrain_map = $"../../../TerrainMap";
var growth = 0;
var turns_alive = 0;

const JUVENILE = 3;
const ADULT = 6;

const DEAD = 10;

const REGION_SIZE = 16;

var adjacent_plant_bonus: int = 0;

var plant_recipe
var sprite;
var points;

var plant_list = [
	{
		"Name": "Daisy",
		"sprite": "res://sprite/daisy.png",
		"points": 3,
	},
	{
		"Name": "Zucchini",
		"sprite": "res://sprite/zucchini.png",
		"points": 5,
	},
	{
		"Name": "Strawberry",
		"sprite": "res://sprite/strawberry.png",
		"points": 7,
	},
]

func _ready():
	sprite = $"Sprite";
	var rnd = RandomNumberGenerator.new();
	plant_recipe = plant_list[rnd.randi_range(0, plant_list.size() - 1)];
	points = plant_recipe.get(points);
	set_phase(0);

func set_phase(phase):
	var atlas_tex = AtlasTexture.new();
	atlas_tex.atlas = load(plant_recipe.get("sprite"));
	atlas_tex.region = Rect2(phase * REGION_SIZE, 0, REGION_SIZE, REGION_SIZE);
	sprite.texture = atlas_tex;

func update_age():
	var terrain_pos = terrain_map.local_to_map(global_position);

	var grass_underneath = terrain_map.get_grass(terrain_pos.x, terrain_pos.y);

	var water_ratio = (float)(grass_underneath.water_amt) / 100;
	var sun_ratio = (float)(grass_underneath.sunlight_amt) / 100;

	
	growth += (sun_ratio) + (water_ratio) * adjacent_plant_bonus;
	if (growth >= JUVENILE && growth < ADULT):
		set_phase(1);
	elif(growth >= ADULT && growth < DEAD):
		set_phase(2);
		
	if (turns_alive >= DEAD):
		return false;
		
	return true;
