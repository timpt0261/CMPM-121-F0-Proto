extends Node2D

@onready var sprite = $"Sprite";
var age = 0;

const JUVENILE = 3;
const ADULT = 7;
const DEAD = 10;

const REGION_SIZE = 16;

func set_sprite(texture):
	sprite.texture.atlas = load(texture);

func set_phase(phase):
	sprite.texture.region = Rect2(REGION_SIZE * phase, 0, REGION_SIZE, REGION_SIZE);

func update_age():
	age += 1;
	if (age >= JUVENILE):
		set_phase(1);
	if(age >= ADULT):
		set_phase(2);
	if(age >= DEAD):
		queue_free();
		
