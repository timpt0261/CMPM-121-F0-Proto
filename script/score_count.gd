extends Label

@onready var plant_manager = $"../../TerrainMap/Plants";
var plant_harvested_count = 0
const MAX_FLOWERS_TO_HARVEST = 5

func _ready():
	# Connect to the signal emitted when a flower is harvested
	plant_manager.connect("harvested_plant", Callable(self, "_on_flower_harvested"));

func _on_flower_harvested():
	plant_harvested_count += 1
	text = "Score: " + str(plant_harvested_count)

	if plant_harvested_count >= MAX_FLOWERS_TO_HARVEST:
		game_over()

func game_over():
	# Show the game over screen or perform any other game over actions
	var game_over_screen = preload("res://scene/game_over.tscn").instantiate() # Adjust the path
	get_tree().current_scene.add_child(game_over_screen)
	game_over_screen.show()
