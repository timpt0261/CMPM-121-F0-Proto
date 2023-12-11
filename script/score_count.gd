class_name ScoreCount extends Label

@onready var terrain_map = $"../../TerrainMap"

var score = 0
var victory_score: int = 0

var translated_text: String = "Score"

func _ready():
	terrain_map.increment_score.connect(increment_score.bind())
	victory_score = get_victory_score("res://data/victory.json")

func increment_score(increment: int):
	set_score(score + increment)

func set_score(score: int):
	self.score = score
	translate_score();
	if self.score >= victory_score:
		game_over()
		
		
func translate_score():
	text = translated_text + ":  " + str(self.score)

func game_over():
	# Show the game over screen or perform any other game over actions
	var game_over_screen = preload("res://scene/game_over.tscn").instantiate()  # Adjust the path
	get_tree().current_scene.add_child(game_over_screen)
	game_over_screen.show()

func get_victory_score(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var dict: Dictionary = JSON.parse_string(file.get_as_text())
	return dict.get("points_to_win")
