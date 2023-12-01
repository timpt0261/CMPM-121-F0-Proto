extends Label

@onready var plant_manager = $"../../game_state_manager/TerrainMap/Plants";

func _ready():
	# Connect to the signal emitted when a flower is harvested
	plant_manager.connect("harvested_plant", Callable(self, "_on_plant_harvested"));

func _on_plant_harvested():
	var plant_harvested_amount = str(plant_manager.get_plant_harvested_amount());
	text = "Score: " + plant_harvested_amount;


