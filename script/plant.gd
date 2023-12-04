class_name Plant extends Sprite2D

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

var plant_template;
var points;
var max_turns;

func _init(plant_template):
	self.plant_template = plant_template
	
func _ready():
	initialize_plant();
	set_phase(0);


func initialize_plant():
	var rnd = RandomNumberGenerator.new();
	points = plant_template.get("points");
	JUVENILE = plant_template.get("juvenile");
	ADULT = plant_template.get("adult");
	DEAD = plant_template.get("dead");
	max_turns = plant_template.get("max_turns");
	
func set_phase(phase):
	var atlas_tex = AtlasTexture.new();
	atlas_tex.atlas = load(plant_template.get("sprite"));
	atlas_tex.region = Rect2(phase * REGION_SIZE, 0, REGION_SIZE, REGION_SIZE);
	texture = atlas_tex;

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
