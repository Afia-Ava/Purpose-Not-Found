extends Control

# Chad's Farm Game - A journey from tech bro to zen farmer
# Simple farming mechanics with discovery and mindfulness

@onready var plant_panel = $MainContainer/PlantPanel
@onready var field_panel = $MainContainer/FieldPanel
@onready var score_label = $MainContainer/UIPanel/ScoreContainer/ScoreLabel
@onready var back_button = $MainContainer/UIPanel/BackButton

var current_score = 0
var selected_plant = ""
var game_started = false

# Plant data with growth times and point values
var plants_data = {
	"🍅 Tomato": {"grow_time": 4.0, "points": 75, "color": Color.TOMATO, "emoji": "🍅"},
	"🥕 Carrot": {"grow_time": 2.5, "points": 50, "color": Color.ORANGE, "emoji": "🥕"},
	"🥬 Lettuce": {"grow_time": 1.5, "points": 35, "color": Color.LIGHT_GREEN, "emoji": "🥬"},
	"🌽 Corn": {"grow_time": 5.0, "points": 100, "color": Color.GOLD, "emoji": "🌽"},
	"🥔 Potato": {"grow_time": 3.5, "points": 65, "color": Color.SADDLE_BROWN, "emoji": "🥔"},
	"🍓 Strawberry": {"grow_time": 3.0, "points": 80, "color": Color.DEEP_PINK, "emoji": "🍓"}
}

# Field management
var planted_crops = []
var field_buttons = []
var plant_buttons = []
var field_size = 12  # 3x4 grid for more farming space

func _ready():
	print("Starting farming game...")
	_setup_scene()
	_create_plant_selection()
	_create_field_grid()
	_connect_signals()

func _setup_scene():
	# Fade in animation
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	
	# Initialize score
	_update_score_display()
	
	# Initialize field arrays
	planted_crops.clear()
	field_buttons.clear()
	plant_buttons.clear()
	
	for i in range(field_size):
		planted_crops.append(null)

func _create_plant_selection():
	print("Creating plant selection...")
	
	# Create plant selection container
	var plant_container = VBoxContainer.new()
	plant_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	plant_container.add_theme_constant_override("separation", 8)
	plant_panel.add_child(plant_container)
	
	# Title
	var title_label = RichTextLabel.new()
	title_label.custom_minimum_size = Vector2(0, 60)
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("default_color", Color.WHITE)
	title_label.bbcode_enabled = true
	title_label.text = "[center][b]🌱 Seeds[/b][/center]"
	title_label.fit_content = true
	plant_container.add_child(title_label)
	
	# Instructions
	var instructions = RichTextLabel.new()
	instructions.custom_minimum_size = Vector2(0, 50)
	instructions.add_theme_font_size_override("font_size", 12)
	instructions.add_theme_color_override("default_color", Color.LIGHT_GRAY)
	instructions.bbcode_enabled = true
	instructions.text = "[center]Select a plant, then click empty fields to plant.[/center]"
	instructions.fit_content = true
	plant_container.add_child(instructions)
	
	# Plant buttons
	for plant_name in plants_data.keys():
		var plant_data = plants_data[plant_name]
		var button = Button.new()
		button.text = plant_name
		button.custom_minimum_size = Vector2(200, 45)
		button.add_theme_font_size_override("font_size", 14)
		button.pressed.connect(_on_plant_selected.bind(plant_name))
		plant_container.add_child(button)
		plant_buttons.append(button)
		
		# Add hover hint
		button.mouse_entered.connect(_show_plant_hint.bind(plant_name))

func _create_field_grid():
	print("Creating field grid...")
	
	# Create field container (3x4 grid)
	var field_container = GridContainer.new()
	field_container.columns = 3
	field_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	field_container.add_theme_constant_override("h_separation", 8)
	field_container.add_theme_constant_override("v_separation", 8)
	field_panel.add_child(field_container)
	
	# Add field title
	var field_title = RichTextLabel.new()
	field_title.custom_minimum_size = Vector2(0, 40)
	field_title.add_theme_font_size_override("font_size", 20)
	field_title.add_theme_color_override("default_color", Color.WHITE)
	field_title.bbcode_enabled = true
	field_title.text = "[center][b]🚜 Chad's Fields[/b][/center]"
	field_title.fit_content = true
	field_container.add_child(field_title)
	
	# Add spacer (takes up 2 grid spaces)
	var spacer1 = Control.new()
	field_container.add_child(spacer1)
	var spacer2 = Control.new()
	field_container.add_child(spacer2)
	
	# Create field buttons
	for i in range(field_size):
		var field_button = Button.new()
		field_button.text = "Empty\nField"
		field_button.custom_minimum_size = Vector2(100, 80)
		field_button.add_theme_font_size_override("font_size", 11)
		field_button.pressed.connect(_on_field_clicked.bind(i))
		field_container.add_child(field_button)
		field_buttons.append(field_button)

func _connect_signals():
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

func _on_plant_selected(plant_name: String):
	selected_plant = plant_name
	print("Selected plant: ", plant_name)
	
	# Update button appearance to show selection
	for button in plant_buttons:
		if button.text == plant_name:
			button.modulate = Color.YELLOW
			button.add_theme_color_override("font_color", Color.BLACK)
		else:
			button.modulate = Color.WHITE
			button.remove_theme_color_override("font_color")

func _show_plant_hint(plant_name: String):
	var plant_data = plants_data[plant_name]
	var grow_time = plant_data["grow_time"]
	var points = plant_data["points"]
	print("Plant hint: ", plant_name, " - Growth time: ", grow_time, "s, Points: ", points)

func _on_field_clicked(field_index: int):
	if selected_plant == "":
		print("No plant selected! Please select a plant first.")
		_show_message("Select a plant first!")
		return
	
	if planted_crops[field_index] != null:
		var crop = planted_crops[field_index]
		if crop.has("ready") and crop["ready"]:
			# Harvest the crop
			_harvest_crop(field_index)
		else:
			print("Field already planted and still growing!")
			_show_message("Field is already planted!")
		return
	
	# Plant the crop
	_plant_crop(field_index)

func _plant_crop(field_index: int):
	print("Planting ", selected_plant, " in field ", field_index)
	
	var plant_data = plants_data[selected_plant].duplicate()
	plant_data["plant_name"] = selected_plant
	plant_data["plant_time"] = Time.get_ticks_msec() / 1000.0
	plant_data["ready"] = false
	planted_crops[field_index] = plant_data
	
	# Update button appearance
	var button = field_buttons[field_index]
	button.text = plant_data["emoji"] + "\nGrowing..."
	button.modulate = plant_data["color"]
	button.add_theme_color_override("font_color", Color.WHITE)
	
	# Start growth timer
	_start_grow_timer(field_index)
	
	# Show planting message
	_show_message("Planted " + selected_plant + "!")

func _start_grow_timer(field_index: int):
	var crop = planted_crops[field_index]
	if crop == null:
		return
	
	var grow_time = crop["grow_time"]
	print("Starting grow timer for ", grow_time, " seconds")
	
	# Create timer
	var timer = Timer.new()
	timer.wait_time = grow_time
	timer.one_shot = true
	timer.timeout.connect(_on_crop_ready.bind(field_index))
	add_child(timer)
	timer.start()

func _on_crop_ready(field_index: int):
	var crop = planted_crops[field_index]
	if crop == null:
		return
	
	print("Crop ready for harvest in field ", field_index)
	crop["ready"] = true
	
	# Update button to show it's ready
	var button = field_buttons[field_index]
	button.text = crop["emoji"] + "\nReady!"
	button.modulate = Color.LIGHT_GREEN
	button.add_theme_color_override("font_color", Color.BLACK)

func _harvest_crop(field_index: int):
	var crop = planted_crops[field_index]
	if crop == null:
		return
	
	print("Harvesting ", crop["plant_name"], " for ", crop["points"], " points")
	
	# Add points
	current_score += crop["points"]
	_update_score_display()
	
	# Show harvest message
	_show_message("Harvested " + crop["plant_name"] + "! +" + str(crop["points"]) + " points")
	
	# Clear the field
	planted_crops[field_index] = null
	var button = field_buttons[field_index]
	button.text = "Empty\nField"
	button.modulate = Color.WHITE
	button.remove_theme_color_override("font_color")

func _update_score_display():
	if score_label:
		score_label.text = "[center][b]Score: " + str(current_score) + "[/b][/center]"

func _show_message(message: String):
	print("Message: ", message)
	# You could add a popup or status text here in the future

func _on_back_pressed():
	print("Going back to farm scene...")
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/farm_scene.tscn")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
