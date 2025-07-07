extends Control

# Cleaning Game Scene Script with Supply Selection and Scoring

@onready var task_list = $MainContainer/TaskPanel/ScrollContainer/TaskList
@onready var cleaning_status = $MainContainer/CleaningArea/CleaningStatus
@onready var back_button = $BackButton
@onready var score_label = $MainContainer/CleaningArea/ScoreBox/ScoreLabel

var selected_task_index = -1
var selected_task = {}
var selected_supplies = []
var player_score = 0
var cleaning_in_progress = false
var current_mode = "task_selection"  # "task_selection", "supply_selection", "cleaning"
var supply_buttons = []

# Cleaning task data with required and optional supplies
var cleaning_tasks = [
	{
		"name": "🍽️ Wash Dishes",
		"description": "Tackle the pile of dirty dishes",
		"required": ["dish_soap", "sponge", "water"],
		"optional": ["scrub_brush", "rubber_gloves", "dish_towel", "degreaser"],
		"steps": [
			"Chad rolls up his sleeves and surveys the mess",
			"He squirts dish soap with scientific precision",
			"The sponge works its magic on stubborn stains",
			"Warm water rinses away the soap and grime",
			"Sparkling clean dishes emerge victorious!"
		]
	},
	{
		"name": "🧽 Scrub the Sink",
		"description": "Make the sink shine like new",
		"required": ["sink_cleaner", "sponge"],
		"optional": ["baking_soda", "scrub_brush", "rubber_gloves", "paper_towels"],
		"steps": [
			"Chad sprays the sink with determined focus",
			"He scrubs in circular motions like a pro",
			"The grime starts to surrender to his efforts",
			"A final rinse reveals the transformation",
			"The sink gleams with newfound brilliance!"
		]
	},
	{
		"name": "🧼 Clean Countertops",
		"description": "Wipe down all the surfaces",
		"required": ["all_purpose_cleaner", "microfiber_cloth"],
		"optional": ["disinfectant", "paper_towels", "rubber_gloves", "sponge"],
		"steps": [
			"Chad surveys the countertop battlefield",
			"He sprays cleaner across every surface",
			"The microfiber cloth glides smoothly",
			"Crumbs and spills vanish without a trace",
			"Perfect! The countertops are spotless"
		]
	},
	{
		"name": "🗑️ Take Out Trash",
		"description": "Deal with the overflowing garbage",
		"required": ["trash_bags", "ties"],
		"optional": ["rubber_gloves", "air_freshener", "disinfectant", "paper_towels"],
		"steps": [
			"Chad ties up the full bag with expertise",
			"He grabs a fresh trash bag for the bin",
			"The trip to the outdoor bin is triumphant",
			"A spritz of air freshener completes the job",
			"Victory! The kitchen smells fresh again"
		]
	},
	{
		"name": "🧹 Sweep and Mop",
		"description": "Clean the floor from top to bottom",
		"required": ["broom", "mop", "floor_cleaner"],
		"optional": ["dustpan", "bucket", "rubber_gloves", "air_freshener"],
		"steps": [
			"Chad sweeps with the confidence of a janitor",
			"Every crumb is captured in his systematic sweep",
			"The mop soaks up the floor cleaner perfectly",
			"He works in efficient sections across the floor",
			"The floor is now spotless and gleaming!"
		]
	}
]

# All available cleaning supplies
var all_supplies = [
	"dish_soap", "sponge", "water", "scrub_brush", "rubber_gloves", "dish_towel",
	"degreaser", "sink_cleaner", "baking_soda", "paper_towels", "all_purpose_cleaner",
	"microfiber_cloth", "disinfectant", "trash_bags", "ties", "air_freshener",
	"broom", "mop", "floor_cleaner", "dustpan", "bucket", "glass_cleaner", "bleach"
]

# Supply display names
var supply_names = {
	"dish_soap": "🧼 Dish Soap",
	"sponge": "🧽 Sponge",
	"water": "💧 Water",
	"scrub_brush": "🪣 Scrub Brush",
	"rubber_gloves": "🧤 Rubber Gloves",
	"dish_towel": "🧺 Dish Towel",
	"degreaser": "🧴 Degreaser",
	"sink_cleaner": "✨ Sink Cleaner",
	"baking_soda": "🧂 Baking Soda",
	"paper_towels": "🧻 Paper Towels",
	"all_purpose_cleaner": "🧽 All-Purpose Cleaner",
	"microfiber_cloth": "🧽 Microfiber Cloth",
	"disinfectant": "🦠 Disinfectant",
	"trash_bags": "🗑️ Trash Bags",
	"ties": "🪢 Twist Ties",
	"air_freshener": "🌸 Air Freshener",
	"broom": "🧹 Broom",
	"mop": "🧽 Mop",
	"floor_cleaner": "🧴 Floor Cleaner",
	"dustpan": "🧹 Dustpan",
	"bucket": "🪣 Bucket",
	"glass_cleaner": "🪟 Glass Cleaner",
	"bleach": "🧴 Bleach"
}

func _ready():
	_setup_scene()
	_create_task_buttons()
	_connect_signals()

func _setup_scene():
	# Fade in animation
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	_update_score_display()

func _update_score_display():
	score_label.text = "[center][b]Score: " + str(player_score) + "[/b][/center]"
	
	# Update initial cleaning status
	cleaning_status.text = "[center][b]Ready to Clean![/b]

Select a cleaning task from the left panel to get started.

Chad stares at the sink full of dishes, wondering if he can figure out the right cleaning supplies...[/center]"

func _connect_signals():
	back_button.pressed.connect(_on_back_pressed)

func _create_task_buttons():
	# Create buttons for each cleaning task
	for i in range(cleaning_tasks.size()):
		var task = cleaning_tasks[i]
		
		# Create task button
		var button = Button.new()
		button.text = task["name"]
		button.custom_minimum_size = Vector2(0, 60)
		button.add_theme_font_size_override("font_size", 18)
		button.add_theme_color_override("font_color", Color.WHITE)
		
		# Add to task list
		task_list.add_child(button)
		
		# Connect button signal
		button.pressed.connect(_on_task_selected.bind(i))
		
		# Add description label
		var desc_label = RichTextLabel.new()
		desc_label.custom_minimum_size = Vector2(0, 40)
		desc_label.bbcode_enabled = true
		desc_label.text = "[center][i]" + task["description"] + "[/i][/center]"
		desc_label.add_theme_font_size_override("font_size", 14)
		desc_label.add_theme_color_override("default_color", Color(0.8, 0.8, 0.8, 1))
		desc_label.fit_content = true
		desc_label.scroll_active = false
		
		task_list.add_child(desc_label)
		
		# Add spacer
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 15)
		task_list.add_child(spacer)

func _on_task_selected(task_index: int):
	if cleaning_in_progress:
		return
	
	selected_task_index = task_index
	selected_task = cleaning_tasks[task_index]
	current_mode = "supply_selection"
	
	# Show supply selection
	_show_supply_selection()

func _show_supply_selection():
	# Clear existing task buttons
	for child in task_list.get_children():
		if child.get_index() > 2:  # Keep title, subtitle, and spacer
			child.queue_free()
	
	# Add "Start Cleaning" button
	var start_button = Button.new()
	start_button.text = "🧽 Start Cleaning"
	start_button.custom_minimum_size = Vector2(0, 50)
	start_button.add_theme_font_size_override("font_size", 20)
	start_button.add_theme_color_override("font_color", Color.GREEN)
	start_button.pressed.connect(_on_start_cleaning_pressed)
	
	task_list.add_child(start_button)
	
	# Add spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 15)
	task_list.add_child(spacer)
	
	# Create supply selection buttons
	supply_buttons.clear()
	for supply in all_supplies:
		var button = Button.new()
		button.text = supply_names.get(supply, supply)
		button.custom_minimum_size = Vector2(0, 40)
		button.add_theme_font_size_override("font_size", 14)
		button.toggle_mode = true
		
		# Add to task list
		task_list.add_child(button)
		
		# Connect button signal
		button.toggled.connect(_on_supply_toggled.bind(supply, button))
		
		# Store button reference
		supply_buttons.append(button)
	
	# Update status
	cleaning_status.text = "[center][b]" + selected_task["name"] + "[/b]

" + selected_task["description"] + "

Select your cleaning supplies from the left panel, then click 'Start Cleaning' when ready.

Chad examines the task ahead, wondering which supplies will lead to success...[/center]"

func _on_supply_toggled(supply: String, button: Button):
	if button.button_pressed:
		if supply not in selected_supplies:
			selected_supplies.append(supply)
			button.add_theme_color_override("font_color", Color.GREEN)
	else:
		if supply in selected_supplies:
			selected_supplies.erase(supply)
			button.add_theme_color_override("font_color", Color.WHITE)
	
	print("DEBUG: Selected supplies: ", selected_supplies)

func _on_start_cleaning_pressed():
	if cleaning_in_progress:
		return
	
	cleaning_in_progress = true
	current_mode = "cleaning"
	
	# Calculate score
	var score = _calculate_score()
	player_score += score
	_update_score_display()
	
	# Start cleaning animation
	_start_cleaning_animation()

func _calculate_score():
	var required_supplies = selected_task["required"]
	var optional_supplies = selected_task["optional"]
	var score = 0
	
	print("DEBUG: Required supplies: ", required_supplies)
	print("DEBUG: Optional supplies: ", optional_supplies)
	print("DEBUG: Selected supplies: ", selected_supplies)
	
	# Check for required supplies
	for supply in required_supplies:
		if supply in selected_supplies:
			score += 50  # Perfect score for required supplies
		else:
			score -= 30  # Penalty for missing required supplies
	
	# No bonus/penalty for optional supplies (hidden scoring)
	
	print("DEBUG: Final score: ", score)
	return score

func _start_cleaning_animation():
	var steps = selected_task["steps"]
	_display_cleaning_steps(steps, 0)

func _display_cleaning_steps(steps: Array, step_index: int):
	if step_index < steps.size():
		var step_text = steps[step_index]
		cleaning_status.text = "[center][b]" + selected_task["name"] + "[/b]

" + step_text + "

[i]Chad is making progress...[/i][/center]"
		
		# Set up timer for next step
		var timer = Timer.new()
		add_child(timer)
		timer.wait_time = 2.0
		timer.timeout.connect(func(): 
			timer.queue_free()
			_display_cleaning_steps(steps, step_index + 1)
		)
		timer.start()
	else:
		# Cleaning complete
		cleaning_status.text = "[center][b]Cleaning Complete![/b]

" + selected_task["name"] + " - DONE! ✅

Chad steps back and admires his work. The cleaning is complete!

[i]Select another task to continue, or go back to the sink.[/i][/center]"
		cleaning_in_progress = false
		current_mode = "task_selection"
		_reset_to_task_selection()

func _reset_to_task_selection():
	# Clear supply selection UI
	for child in task_list.get_children():
		if child.get_index() > 2:  # Keep title, subtitle, and spacer
			child.queue_free()
	
	# Reset variables
	selected_task_index = -1
	selected_task = {}
	selected_supplies.clear()
	supply_buttons.clear()
	current_mode = "task_selection"
	
	# Recreate task buttons
	_create_task_buttons()
	
	# Update status
	cleaning_status.text = "[center][b]Ready to Clean![/b]

Select a cleaning task from the left panel to get started.

Chad stares at the sink full of dishes, wondering if he can figure out the right cleaning supplies...[/center]"

func _on_back_pressed():
	print("DEBUG: Back button pressed")
	get_tree().change_scene_to_file("res://scenes/sink_scene.tscn")
