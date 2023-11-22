extends Node2D

var age = 0;
var sprite = null;

const JUVENILE = 3;
const ADULT = 7;
const DEAD = 10;

const REGION_SIZE = 16;

func _ready():
	sprite = $"Sprite";
	#sprite.region_enabled = true;

func set_sprite(texture):
	sprite.texture.atlas = load(texture);

func set_phase(phase):
	sprite.texture.region = Rect2(REGION_SIZE * phase, 0, REGION_SIZE, REGION_SIZE);
	#sprite.region_rect = Rect2(REGION_SIZE * phase, 0, REGION_SIZE, REGION_SIZE);
	#print(phase);
	print(sprite.region_rect);

func update_age():
	age += 1;
	if (age >= JUVENILE && age <= ADULT):
		set_phase(1);
	if(age >= ADULT):
		set_phase(2);
	#if(age >= DEAD):
	#	queue_free();
