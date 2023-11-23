extends Control

@onready var score_count_label = $"../../ScoreCount"  # Adjust the path based on your scene structure
@onready var plant_manger = preload("res://script/plant_manager.gd");
var flower_harvested_count = 0
const MAX_FLOWERS_TO_HARVEST = 5

func _ready():
	# Connect to the signal emitted when a flower is harvested
	plant_manager.connect("harvest_plants", self, "_on_flower_harvested")

func _on_flower_harvested():
	flower_harvested_count += 1
	score_count_label.text = "Score: " + str(flower_harvested_count)

	if flower_harvested_count >= MAX_FLOWERS_TO_HARVEST:
		game_over()

func game_over():
	# Show the game over screen or perform any other game over actions
	var game_over_screen = preload("res://scene/game_over.tscn").instance()  # Adjust the path
	get_tree().current_scene.add_child(game_over_screen)
	game_over_screen.centered = true
	game_over_screen.rect_min_size = Vector2(400, 200)
	game_over_screen.show()
