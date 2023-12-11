class_name GrowthContext

var hydration: int
var sunlight: int
var plant: Plant
var adjacent_plant_ids: Array[int]

func _init(hydration: int, sunlight: int, plant: Plant, adjacent_plant_ids: Array[int]):
	self.hydration = hydration
	self.sunlight = sunlight
	self.adjacent_plant_ids = adjacent_plant_ids
	self.plant = plant
