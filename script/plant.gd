class_name Plant

var id: int
var growth: int
var turns_alive: int

func _init(id: int, growth: int, turns_alive: int):
	self.id = id
	self.growth = growth
	self.turns_alive = turns_alive

func get_visual_phase() -> int:
	var growth_caps: Array[int] = PlantTemplates.get_templates()[id].growth_caps
	for i in growth_caps.size():
		if growth < growth_caps[i]:
			return i
	return growth_caps.size()

func is_dead() -> bool:
	var my_template = PlantTemplates.get_templates()[id]
	return turns_alive > my_template.max_turns || growth >= my_template.growth_caps[my_template.growth_caps.size()-1];
