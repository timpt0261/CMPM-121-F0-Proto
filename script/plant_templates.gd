class_name PlantTemplates

static var template_programs: Array[Callable] = [
	func(dsl: PlantTemplateDSL):
		dsl.id(0)
		dsl.name("Daisy")
		dsl.points(3)
		dsl.texture(load("res://sprite/daisy.png"))
		dsl.growth_caps([2, 5, 25])
		dsl.max_turns(30)
		dsl.grow(func(ctx: GrowthContext):
			var water_ratio = ctx.hydration / 100.0
			if ctx.adjacent_plant_ids.is_empty():
				return
			ctx.plant.growth += 3*(1.0 / ctx.adjacent_plant_ids.size())),
	func(dsl: PlantTemplateDSL):
		dsl.id(1)
		dsl.name("Strawberry")
		dsl.points(7)
		dsl.texture(load("res://sprite/strawberry.png"))
		dsl.growth_caps([2, 6, 25])
		dsl.max_turns(35)
		dsl.grow(func(ctx: GrowthContext):
			var water_ratio = ctx.hydration / 100.0
			ctx.plant.growth += 3*(-pow(2*water_ratio-1, 2) + 1)
			print("Total: " + str(ctx.plant.growth))),
	func(dsl: PlantTemplateDSL):
		dsl.id(2)
		dsl.name("Zucchini")
		dsl.points(5)
		dsl.texture(load("res://sprite/zucchini.png"))
		dsl.growth_caps([2, 7, 25])
		dsl.max_turns(32)
		dsl.grow(func(ctx: GrowthContext):
			var water_ratio = ctx.hydration / 100.0
			var sun_ratio = ctx.sunlight / 100.0
			if water_ratio > 0.3 || sun_ratio > 0.5:
				return
			ctx.plant.growth += 3*(sun_ratio / 0.5)
			print("Total: " + str(ctx.plant.growth)))
]
static var templates: Array[PlantTemplate] = get_compiled_templates()

static func get_templates() -> Array[PlantTemplate]:
	return templates

static func get_compiled_templates() -> Array[PlantTemplate]:
	var templates: Array[PlantTemplate]= []
	templates.resize(template_programs.size())
	for i in template_programs.size():
		templates[i] = PlantTemplateDSLCompiler.compile(template_programs[i])
	return templates

class PlantTemplateDSLCompiler:
	static func compile(program: Callable) -> PlantTemplate:
		var plant_template = PlantTemplate.new()
		
		program.call(PlantCompilerDsl.new(plant_template));
		
		return plant_template
	
class PlantCompilerDsl extends PlantTemplateDSL:
	var plant_template: PlantTemplate
	
	func _init(plant_template):
		self.plant_template = plant_template
		
	func id(id: int):
		plant_template.id = id
	func name(name: String):
		plant_template.name = name
	func points(points: int):
		plant_template.points = points
	func texture(texture: Texture2D):
		plant_template.texture = texture
	func growth_caps(growth_caps: Array[int]):
		plant_template.growth_caps = growth_caps
	func max_turns(max_turns: int):
		plant_template.max_turns = max_turns
	func grow(grow: Callable):
		plant_template.grow = grow
