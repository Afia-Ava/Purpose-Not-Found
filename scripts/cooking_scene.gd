extends Control

# Cooking Scene Script
# Interactive cooking interface with dish selection and ingredient choosing

@onready var cooking_elements = $RightSidebar/ScrollContainer/CookingElements
@onready var title_label = $RightSidebar/ScrollContainer/CookingElements/Title
@onready var back_button = $RightSidebar/ScrollContainer/CookingElements/ActionButtons/BackButton
@onready var cooking_status = $CookingArea/CookingStatus
@onready var kitchen_background = $Background
@onready var cook_pan_background = $CookPanBackground
@onready var cooking_area = $CookingArea

var back_to_kitchen_button: Button

var selected_ingredients: Array[String] = []
var selected_dish: String = ""
var cooking_mode: String = "dish_selection"  # "dish_selection" or "ingredient_selection"
var current_step: int = 0

# Available dishes and their required/optional ingredients
var dishes = {
	"scrambled_eggs": {
		"name": "🍳 Scrambled Eggs",
		"required": ["eggs", "pan"],
		"optional": ["butter", "salt", "pepper", "cheese", "milk"],
		"description": "Classic breakfast dish - perfect for beginners!"
	},
	"pasta": {
		"name": "🍝 Simple Pasta",
		"required": ["pasta", "pot", "water"],
		"optional": ["salt", "olive_oil", "garlic", "cheese", "tomatoes"],
		"description": "Easy comfort food that even Chad can't mess up."
	},
	"soup": {
		"name": "🍲 Vegetable Soup",
		"required": ["pot", "water", "vegetables"],
		"optional": ["salt", "pepper", "onion", "garlic", "herbs"],
		"description": "Healthy and warming - Sandra would approve!"
	},
	"grilled_cheese": {
		"name": "🧀 Grilled Cheese",
		"required": ["bread", "cheese", "pan"],
		"optional": ["butter", "tomato", "ham", "herbs"],
		"description": "Crispy, cheesy comfort food that hits the spot."
	},
	"pancakes": {
		"name": "🥞 Fluffy Pancakes",
		"required": ["flour", "eggs", "milk", "pan"],
		"optional": ["butter", "sugar", "vanilla", "berries", "syrup"],
		"description": "Weekend morning special - stack 'em high!"
	},
	"stir_fry": {
		"name": "🥢 Vegetable Stir Fry",
		"required": ["vegetables", "pan", "soy_sauce"],
		"optional": ["garlic", "ginger", "sesame_oil", "rice", "tofu"],
		"description": "Quick and healthy - perfect for busy evenings."
	},
	"omelette": {
		"name": "🍳 French Omelette",
		"required": ["eggs", "pan", "butter"],
		"optional": ["cheese", "herbs", "mushrooms", "ham", "spinach"],
		"description": "Fancy breakfast that shows off your skills."
	},
	"salad": {
		"name": "🥗 Fresh Garden Salad",
		"required": ["lettuce", "vegetables"],
		"optional": ["tomatoes", "cucumber", "dressing", "nuts", "cheese"],
		"description": "Light and refreshing - no cooking required!"
	},
	"rice_bowl": {
		"name": "🍚 Hearty Rice Bowl",
		"required": ["rice", "pot", "water"],
		"optional": ["vegetables", "soy_sauce", "egg", "sesame_oil", "scallions"],
		"description": "Filling and versatile - customize to your liking."
	},
	"sandwich": {
		"name": "🥪 Gourmet Sandwich",
		"required": ["bread", "filling"],
		"optional": ["lettuce", "tomato", "cheese", "mayo", "mustard"],
		"description": "Classic lunch option - build it your way."
	}
}

# All available ingredients
var all_ingredients = {
	"eggs": "🥚 Eggs",
	"pan": "🍳 Pan", 
	"pot": "🍲 Pot",
	"butter": "🧈 Butter",
	"salt": "🧂 Salt",
	"pepper": "🌶️ Pepper",
	"cheese": "🧀 Cheese",
	"milk": "🥛 Milk",
	"pasta": "🍜 Pasta",
	"water": "💧 Water",
	"olive_oil": "🫒 Olive Oil",
	"garlic": "🧄 Garlic",
	"tomatoes": "🍅 Tomatoes",
	"vegetables": "🥕 Mixed Vegetables",
	"onion": "🧅 Onion",
	"herbs": "🌿 Fresh Herbs",
	"bread": "🍞 Bread",
	"ham": "🍖 Ham",
	"flour": "🌾 Flour",
	"sugar": "🍯 Sugar",
	"vanilla": "🍦 Vanilla",
	"berries": "🫐 Berries",
	"syrup": "🍯 Maple Syrup",
	"soy_sauce": "🥢 Soy Sauce",
	"ginger": "🫚 Ginger",
	"sesame_oil": "🫒 Sesame Oil",
	"rice": "🍚 Rice",
	"tofu": "🍆 Tofu",
	"mushrooms": "🍄 Mushrooms",
	"spinach": "🥬 Spinach",
	"lettuce": "🥬 Lettuce",
	"cucumber": "🥒 Cucumber",
	"dressing": "🥗 Dressing",
	"nuts": "🥜 Nuts",
	"scallions": "🧅 Scallions",
	"filling": "🥩 Sandwich Filling",
	"mayo": "🥄 Mayonnaise",
	"mustard": "🌭 Mustard"
}

func _ready():
	_setup_scene()

func _setup_scene():
	# Add fade-in animation
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	
	# Set up white font styling for UI elements
	title_label.add_theme_color_override("default_color", Color.WHITE)
	cooking_status.add_theme_color_override("default_color", Color.WHITE)
	
	# Create "Back to Kitchen" button in the cooking area
	_create_back_to_kitchen_button()
	
	# Start with dish selection
	_show_dish_selection()
	_connect_back_button()

func _connect_back_button():
	# Clear any existing connections
	if back_button.pressed.is_connected(_on_back_pressed):
		back_button.pressed.disconnect(_on_back_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _show_dish_selection():
	cooking_mode = "dish_selection"
	title_label.text = "[center][b]Choose Your Dish[/b][/center]"
	_clear_dynamic_buttons()
	
	# Create dish selection buttons
	for dish_key in dishes.keys():
		var dish_info = dishes[dish_key]
		var button = Button.new()
		button.text = dish_info["name"]
		button.custom_minimum_size = Vector2(0, 60)
		button.add_theme_font_size_override("font_size", 18)
		button.add_theme_color_override("font_color", Color.WHITE)
		
		# Insert before the action buttons
		var action_buttons = cooking_elements.get_node("ActionButtons")
		var index = action_buttons.get_index()
		cooking_elements.add_child(button)
		cooking_elements.move_child(button, index)
		
		# Connect the button
		button.pressed.connect(_on_dish_selected.bind(dish_key))
	
	_update_cooking_status_for_dish_selection()

func _show_ingredient_selection():
	cooking_mode = "ingredient_selection"
	var dish_info = dishes[selected_dish]
	title_label.text = "[center][b]Add Ingredients[/b][/center]"
	_clear_dynamic_buttons()
	
	# Show selected dish info
	var dish_info_label = RichTextLabel.new()
	dish_info_label.custom_minimum_size = Vector2(0, 80)
	dish_info_label.bbcode_enabled = true
	dish_info_label.text = "[center][b]" + dish_info["name"] + "[/b]\n\n" + dish_info["description"] + "[/center]"
	dish_info_label.fit_content = true
	dish_info_label.scroll_active = false
	dish_info_label.add_theme_font_size_override("font_size", 14)
	dish_info_label.add_theme_color_override("default_color", Color.WHITE)
	
	var action_buttons = cooking_elements.get_node("ActionButtons")
	var index = action_buttons.get_index()
	cooking_elements.add_child(dish_info_label)
	cooking_elements.move_child(dish_info_label, index)
	
	# Add spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	cooking_elements.add_child(spacer)
	cooking_elements.move_child(spacer, index + 1)
	
	# Create ingredient buttons
	for ingredient_key in all_ingredients.keys():
		var button = Button.new()
		button.text = all_ingredients[ingredient_key]
		button.custom_minimum_size = Vector2(0, 50)
		button.add_theme_font_size_override("font_size", 16)
		button.add_theme_color_override("font_color", Color.WHITE)
		
		# Highlight required ingredients
		if ingredient_key in dish_info["required"]:
			button.modulate = Color(1.0, 0.8, 0.8, 1.0)  # Light red for required
		
		cooking_elements.add_child(button)
		cooking_elements.move_child(button, -2)  # Before action buttons
		
		# Connect the button
		button.pressed.connect(_on_ingredient_selected.bind(ingredient_key))
	
	# Add start cooking button
	var start_button = Button.new()
	start_button.text = "🔥 Start Cooking!"
	start_button.custom_minimum_size = Vector2(0, 50)
	start_button.add_theme_font_size_override("font_size", 20)
	start_button.add_theme_color_override("font_color", Color.WHITE)
	
	# Insert before the action buttons
	var action_buttons = cooking_elements.get_node("ActionButtons")
	var index = action_buttons.get_index()
	cooking_elements.add_child(start_button)
	cooking_elements.move_child(start_button, index)
	
	# Connect the button after it's properly added
	start_button.pressed.connect(_on_start_cooking_pressed)
	
	_update_cooking_status_for_ingredients()

func _clear_dynamic_buttons():
	# Remove all children except the original ones
	var children_to_remove = []
	for child in cooking_elements.get_children():
		if child.name not in ["Title", "Spacer1", "ActionButtons"]:
			children_to_remove.append(child)
	
	for child in children_to_remove:
		child.queue_free()

func _on_dish_selected(dish_key: String):
	selected_dish = dish_key
	selected_ingredients.clear()
	_show_ingredient_selection()

func _on_ingredient_selected(ingredient: String):
	if ingredient in selected_ingredients:
		# Remove if already selected
		selected_ingredients.erase(ingredient)
	else:
		# Add to selection
		selected_ingredients.append(ingredient)
	
	_update_ingredient_button_states()
	_update_cooking_status_for_ingredients()

func _update_ingredient_button_states():
	# Update visual state of ingredient buttons
	for child in cooking_elements.get_children():
		if child is Button and child.text in all_ingredients.values():
			var ingredient_key = ""
			for key in all_ingredients.keys():
				if all_ingredients[key] == child.text:
					ingredient_key = key
					break
			
			if ingredient_key in selected_ingredients:
				child.modulate = Color(0.8, 1.0, 0.8, 1.0)  # Green for selected
			elif ingredient_key in dishes[selected_dish]["required"]:
				child.modulate = Color(1.0, 0.8, 0.8, 1.0)  # Light red for required
			else:
				child.modulate = Color(1.0, 1.0, 1.0, 1.0)  # Normal

func _update_cooking_status_for_dish_selection():
	cooking_status.text = "[center][b]🍳 Chad's Cooking Adventure[/b]

Choose what you want to make from the sidebar!

[i]Chad stands in the kitchen, feeling slightly less overwhelmed now that he has a plan. Sandra's voice echoes: 'Start simple, think big.'[/i]

What sounds good today?[/center]"

func _update_cooking_status_for_ingredients():
	if not selected_dish:
		return
	
	var dish_info = dishes[selected_dish]
	var missing_required = []
	
	# Check for missing required ingredients
	for req in dish_info["required"]:
		if req not in selected_ingredients:
			missing_required.append(all_ingredients[req])
	
	var status_text = "[center][b]Making: " + dish_info["name"] + "[/b]\n\n"
	
	if selected_ingredients.is_empty():
		status_text += "Select ingredients from the sidebar!\n\n[color=red]Required:[/color]\n"
		for req in dish_info["required"]:
			status_text += "• " + all_ingredients[req] + "\n"
	else:
		status_text += "[b]In the pot:[/b]\n"
		for ingredient in selected_ingredients:
			status_text += "• " + all_ingredients[ingredient] + "\n"
		
		if missing_required.size() > 0:
			status_text += "\n[color=red]Still need:[/color]\n"
			for req in missing_required:
				status_text += "• " + req + "\n"
		else:
			status_text += "\n[color=green]Ready to cook![/color]"
	
	status_text += "[/center]"
	cooking_status.text = status_text

func _on_start_cooking_pressed():
	if not selected_dish:
		_show_message("Please select a dish first!")
		return
	
	var dish_info = dishes[selected_dish]
	var missing_required = []
	
	# Check for required ingredients
	for req in dish_info["required"]:
		if req not in selected_ingredients:
			missing_required.append(all_ingredients[req])
	
	if missing_required.size() > 0:
		var message = "You're missing required ingredients:\n"
		for req in missing_required:
			message += "• " + req + "\n"
		_show_message(message)
		return
	
	# Start the cooking sequence
	_start_cooking_sequence()

func _start_cooking_sequence():
	# Switch to cook-pan background
	kitchen_background.visible = false
	cook_pan_background.visible = true
	
	var cooking_steps = _generate_cooking_steps()
	current_step = 0
	_advance_cooking_step(cooking_steps)

func _generate_cooking_steps() -> Array[String]:
	var steps: Array[String] = []
	
	match selected_dish:
		"scrambled_eggs":
			steps = [
				"Chad nervously picks up the pan...",
				"He cracks the eggs with surprising confidence.",
				"The eggs sizzle as they hit the heated pan.",
				"Chad scrambles them gently, remembering Sandra's advice about patience.",
				"The aroma fills the kitchen - it actually smells like food!"
			]
			if "cheese" in selected_ingredients:
				steps.append("A sprinkle of cheese melts perfectly on top.")
			if "salt" in selected_ingredients or "pepper" in selected_ingredients:
				steps.append("Seasoning adds the perfect finishing touch.")
			steps.append("Success! Chad's first scrambled eggs are ready.")
		
		"pasta":
			steps = [
				"Chad fills the pot with water.",
				"The water bubbles energetically on the stove.",
				"Pasta goes in with a satisfying splash.",
				"Chad stirs occasionally, feeling like a real chef."
			]
			if "salt" in selected_ingredients:
				steps.append("A pinch of salt enhances the pasta water.")
			if "olive_oil" in selected_ingredients:
				steps.append("Olive oil prevents the pasta from sticking.")
			steps.append("The pasta is perfectly al dente!")
		
		"soup":
			steps = [
				"Chad chops the vegetables with newfound determination.",
				"The pot heats up as vegetables are added.",
				"Water transforms the ingredients into something magical.",
				"Steam rises, carrying wonderful aromas."
			]
			if "herbs" in selected_ingredients:
				steps.append("Fresh herbs add a gourmet touch.")
			steps.append("The soup simmers to perfection.")
		
		"grilled_cheese":
			steps = [
				"Chad butters the bread with careful precision.",
				"The cheese goes on thick - this is no time for moderation.",
				"The pan heats up as the sandwich sizzles.",
				"Golden brown perfection is within reach."
			]
			if "tomato" in selected_ingredients:
				steps.append("Fresh tomato slices add a gourmet touch.")
			if "ham" in selected_ingredients:
				steps.append("Ham makes this a proper meal.")
			steps.append("The grilled cheese is crispy, cheesy perfection!")
		
		"pancakes":
			steps = [
				"Chad measures flour like he's conducting a science experiment.",
				"Eggs crack into the bowl with satisfying precision.",
				"The batter comes together into something... promising.",
				"First pancake hits the pan with a confident sizzle."
			]
			if "berries" in selected_ingredients:
				steps.append("Fresh berries dot the pancakes like edible confetti.")
			if "syrup" in selected_ingredients:
				steps.append("Maple syrup cascades down like liquid gold.")
			steps.append("Stack complete! Chad's pancakes are fluffy and perfect.")
		
		"stir_fry":
			steps = [
				"Chad heats the pan until it's smoking hot.",
				"Vegetables hit the pan with dramatic sizzling.",
				"The stir-fry technique is surprisingly therapeutic.",
				"Colors blend as ingredients dance in the pan."
			]
			if "garlic" in selected_ingredients:
				steps.append("Garlic adds aromatic depth to the dish.")
			if "ginger" in selected_ingredients:
				steps.append("Fresh ginger brings warmth and spice.")
			steps.append("The stir-fry is vibrant, healthy, and delicious!")
		
		"omelette":
			steps = [
				"Chad whisks eggs with the focus of a zen master.",
				"Butter melts in the pan like yellow silk.",
				"The eggs flow in, creating a perfect canvas.",
				"The folding technique requires surgical precision."
			]
			if "cheese" in selected_ingredients:
				steps.append("Cheese melts into creamy perfection.")
			if "herbs" in selected_ingredients:
				steps.append("Fresh herbs elevate this to restaurant quality.")
			steps.append("The omelette is French-level sophisticated!")
		
		"salad":
			steps = [
				"Chad washes the lettuce with unexpected care.",
				"Each vegetable is chopped with mindful precision.",
				"The bowl becomes a canvas of colors and textures.",
				"Assembly requires an artist's eye."
			]
			if "dressing" in selected_ingredients:
				steps.append("Dressing brings all the flavors together.")
			if "nuts" in selected_ingredients:
				steps.append("Nuts add satisfying crunch and protein.")
			steps.append("The salad is fresh, crisp, and surprisingly filling!")
		
		"rice_bowl":
			steps = [
				"Chad rinses the rice until the water runs clear.",
				"The rice cooker becomes his new best friend.",
				"Steam rises as the rice reaches perfection.",
				"Bowl assembly is like building edible architecture."
			]
			if "vegetables" in selected_ingredients:
				steps.append("Colorful vegetables make this a complete meal.")
			if "egg" in selected_ingredients:
				steps.append("A perfectly cooked egg crowns the bowl.")
			steps.append("The rice bowl is comfort food at its finest!")
		
		"sandwich":
			steps = [
				"Chad selects the bread with the seriousness of a sommelier.",
				"Layer by layer, the sandwich architecture takes shape.",
				"Each ingredient is placed with deliberate care.",
				"The final construction is a work of art."
			]
			if "lettuce" in selected_ingredients:
				steps.append("Fresh lettuce adds essential crunch.")
			if "cheese" in selected_ingredients:
				steps.append("Cheese binds everything together perfectly.")
			steps.append("The sandwich is a masterpiece of flavor and texture!")
	
	return steps

func _advance_cooking_step(cooking_steps: Array[String]):
	if current_step < cooking_steps.size():
		cooking_status.text = "[center][b]Cooking in Progress...[/b]

" + cooking_steps[current_step] + "

[i]Step " + str(current_step + 1) + " of " + str(cooking_steps.size()) + "[/i][/center]"
		
		current_step += 1
		await get_tree().create_timer(3.0).timeout
		_advance_cooking_step(cooking_steps)
	else:
		_finish_cooking()

func _finish_cooking():
	var dish_info = dishes[selected_dish]
	cooking_status.text = "[center][b]🎉 Cooking Complete! 🎉[/b]

Chad has successfully made " + dish_info["name"] + "!

[i]The transformation is real - from tech bro who lived on energy drinks to someone who can actually create food. This " + dish_info["name"].to_lower() + " might not be restaurant quality, but it's made with his own hands.[/i]

[b]Achievement Unlocked: " + dish_info["name"] + " Master![/b][/center]"
	
	# Enable back button to return
	await get_tree().create_timer(3.0).timeout
	_show_completion_message()

func _show_completion_message():
	var dish_info = dishes[selected_dish]
	var popup = AcceptDialog.new()
	popup.title = "Cooking Success!"
	popup.dialog_text = "Chad's " + dish_info["name"] + " is ready! 🍳\n\nEach ingredient you chose added its own magic to the dish. This is more than just food - it's proof that Chad can learn, grow, and create.\n\nSandra would definitely be proud of this progress!"
	add_child(popup)
	popup.popup_centered()
	
	popup.confirmed.connect(_on_completion_acknowledged)

func _on_completion_acknowledged():
	# Return to kitchen scene
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/kitchen_scene.tscn")

func _show_message(message: String):
	var popup = AcceptDialog.new()
	popup.title = "Cooking Tip"
	popup.dialog_text = message
	add_child(popup)
	popup.popup_centered()

func _on_back_pressed():
	if cooking_mode == "ingredient_selection":
		# Go back to dish selection and switch back to kitchen background
		kitchen_background.visible = true
		cook_pan_background.visible = false
		_show_dish_selection()
	else:
		# Go back to kitchen scene
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.5)
		await tween.finished
		get_tree().change_scene_to_file("res://scenes/kitchen_scene.tscn")

func _input(event):
	# Allow pressing Escape to go back
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
