class_name ScoreCount extends Label

@onready var terrain_map = $"../../TerrainMap"

var score = 0
const VICTORY_SCORE = 100


func _ready():
	terrain_map.increment_score.connect(increment_score.bind())


func increment_score(increment: int):
	set_score(score + increment)


func set_score(score: int):
	self.score = score
	text = "Score: " + str(self.score)
	if self.score >= VICTORY_SCORE:
		game_over()


func game_over():
	# Show the game over screen or perform any other game over actions
	var game_over_screen = preload("res://scene/game_over.tscn").instantiate()  # Adjust the path
	get_tree().current_scene.add_child(game_over_screen)
	game_over_screen.show()
