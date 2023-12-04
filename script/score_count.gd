class_name ScoreCount extends Label

@onready var plant_manager = $"../../TerrainMap/Plants";

func _ready():
	# Connect to the signal emitted when a flower is harvested
	plant_manager.harvested_plant.connect(_on_plant_harvested.bind());

func _on_plant_harvested():
	var plant_harvested_amount = str(plant_manager.get_plant_harvested_amount());
	text = "Score: " + plant_harvested_amount;


