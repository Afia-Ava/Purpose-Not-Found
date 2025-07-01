extends Node2D
class_name CharacterVisuals

enum CharacterState {
	TECH_BRO,      
	TRANSITIONING,   
	FARMER_CASUAL, 
	ZEN_FARMER     
}

@export var character_state: CharacterState = CharacterState.TECH_BRO
@export var body_color: Color = Color(0.8, 0.6, 0.4, 1)
@export var clothing_color: Color = Color(0.3, 0.3, 0.3, 1)

@onready var body_sprite: ColorRect
@onready var clothing_sprite: ColorRect  
@onready var accessory_sprite: Node2D
@onready var expression_label: Label

var expressions = {
	"stressed": "😤",
	"confused": "🤔", 
	"happy": "😊",
	"zen": "🧘‍♂️",
	"excited": "🤩",
	"tired": "😴",
	"contemplative": "🤨",
	"proud": "😌"
}

var outfits = {
	CharacterState.TECH_BRO: {
		"clothing_color": Color(0.3, 0.3, 0.3, 1), 
		"accessory": "💻",  
		"posture": "slouched"
	},
	CharacterState.TRANSITIONING: {
		"clothing_color": Color(0.4, 0.5, 0.6, 1), 
		"accessory": "🌱", 
		"posture": "improving"
	},
	CharacterState.FARMER_CASUAL: {
		"clothing_color": Color(0.5, 0.7, 0.4, 1),
		"accessory": "🧑‍🌾", 
		"posture": "confident"
	},
	CharacterState.ZEN_FARMER: {
		"clothing_color": Color(0.6, 0.8, 0.5, 1),  
		"accessory": "✨", 
		"posture": "grounded"
	}
}

func _ready():
	_setup_visual_components()
	_update_appearance()

func _setup_visual_components():
	if not body_sprite:
		body_sprite = ColorRect.new()
		body_sprite.size = Vector2(50, 100)
		body_sprite.position = Vector2(-25, -50)
		body_sprite.color = body_color
		add_child(body_sprite)
	if not clothing_sprite:
		clothing_sprite = ColorRect.new()
		clothing_sprite.size = Vector2(60, 60)
		clothing_sprite.position = Vector2(-30, -40)
		add_child(clothing_sprite)	
	if not expression_label:
		expression_label = Label.new()
		expression_label.position = Vector2(-15, -70)
		expression_label.size = Vector2(30, 20)
		expression_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(expression_label)

func update_character_state(new_state: CharacterState):
	character_state = new_state
	_update_appearance()

func set_expression(mood: String):
	if mood in expressions:
		expression_label.text = expressions[mood]

func _update_appearance():
	if character_state in outfits:
		var outfit = outfits[character_state]
		clothing_sprite.color = outfit["clothing_color"]
		
		match outfit["posture"]:
			"slouched":
				rotation_degrees = 5
				scale = Vector2(0.9, 0.9)
			"improving":
				rotation_degrees = 2
				scale = Vector2(0.95, 0.95)
			"confident":
				rotation_degrees = 0
				scale = Vector2(1.0, 1.0)
			"grounded":
				rotation_degrees = 0
				scale = Vector2(1.05, 1.05)

func react_to_dialogue(emotion: String):
	set_expression(emotion)	
	var tween = create_tween()
	match emotion:
		"excited":
			tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
			tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
		"stressed":
			tween.tween_property(self, "rotation_degrees", 5, 0.1)
			tween.tween_property(self, "rotation_degrees", -5, 0.1)
			tween.tween_property(self, "rotation_degrees", 0, 0.1)
		"zen":
			tween.tween_property(self, "modulate", Color(1, 1, 1, 0.8), 0.5)
			tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)

func celebrate_achievement():
	var tween = create_tween()
	set_expression("proud")
	tween.tween_property(self, "position", position + Vector2(0, -20), 0.3)
	tween.tween_property(self, "position", position, 0.3)

func show_growth(skill_type: String):
	match skill_type:
		"cooking":
			_show_temporary_accessory("👨‍🍳", 2.0)
		"farming":
			_show_temporary_accessory("🌱", 2.0)
		"emotional":
			_show_temporary_accessory("💚", 2.0)

func _show_temporary_accessory(accessory: String, duration: float):
	var temp_label = Label.new()
	temp_label.text = accessory
	temp_label.position = Vector2(-10, -90)
	temp_label.size = Vector2(20, 20)
	temp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(temp_label)	
	var tween = create_tween()
	tween.tween_property(temp_label, "position", temp_label.position + Vector2(0, -30), duration)
	tween.tween_property(temp_label, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(temp_label.queue_free)