extends Control

# Simple Cooking Scene Script with Ingredient Selection and Scoring

@onready var recipe_list = $MainContainer/RecipePanel/ScrollContainer/RecipeList
@onready var cooking_status = $MainContainer/CookingArea/CookingStatus
@onready var back_button = $BackButton
@onready var score_label = $ScoreBox/ScoreLabel

var selected_recipe_index = -1
var selected_recipe = {}
var selected_ingredients = []
var player_score = 0
var cooking_in_progress = false
var current_mode = "recipe_selection"  # "recipe_selection", "ingredient_selection", "cooking"
var ingredient_buttons = []

# Recipe data with required and optional ingredients
var recipes = [
	{
		"name": "🍳 Scrambled Eggs",
		"description": "Simple and delicious breakfast",
		"required": ["eggs", "pan", "butter"],
		"optional": ["salt", "pepper", "cheese", "milk"],
		"steps": [
			"Chad nervously cracks the eggs into a bowl",
			"He whisks them with surprising confidence", 
			"The pan heats up as butter melts perfectly",
			"The eggs sizzle and start to scramble",
			"Perfect! Golden, fluffy scrambled eggs"
		]
	},
	{
		"name": "🍝 Simple Pasta",
		"description": "Easy comfort food classic",
		"required": ["pasta", "pot", "water"],
		"optional": ["salt", "olive_oil", "garlic", "cheese", "tomatoes"],
		"steps": [
			"Chad fills the pot with water and puts it on the stove",
			"The water bubbles energetically as it boils",
			"Pasta goes in with a satisfying splash", 
			"He stirs occasionally, feeling accomplished",
			"The pasta is perfectly cooked and ready!"
		]
	},
	{
		"name": "🥗 Fresh Salad",
		"description": "Healthy and no cooking required",
		"required": ["lettuce", "vegetables"],
		"optional": ["tomatoes", "cucumber", "dressing", "nuts", "cheese"],
		"steps": [
			"Chad carefully washes the fresh lettuce",
			"He chops vegetables with newfound precision",
			"Each ingredient is arranged thoughtfully",
			"A light dressing brings everything together",
			"A beautiful, fresh salad is complete!"
		]
	},
	{
		"name": "🧀 Grilled Cheese",
		"description": "Crispy, cheesy comfort food",
		"required": ["bread", "cheese", "pan"],
		"optional": ["butter", "tomato", "ham", "herbs"],
		"steps": [
			"Chad butters the bread like a pro",
			"Cheese goes on thick - no holding back",
			"The sandwich sizzles in the hot pan",
			"Golden brown perfection is achieved",
			"The ultimate grilled cheese is ready!"
		]
	},
	{
		"name": "🥞 Fluffy Pancakes",
		"description": "Weekend morning special",
		"required": ["flour", "eggs", "milk", "pan"],
		"optional": ["sugar", "vanilla", "berries", "syrup", "butter"],
		"steps": [
			"Chad measures flour like a scientist",
			"Eggs crack into the bowl perfectly",
			"The batter comes together beautifully",
			"First pancake hits the pan with confidence",
			"Stack complete! Fluffy pancake perfection"
		]
	}
]

# All available ingredients
var all_ingredients = [
	"eggs", "pan", "butter", "salt", "pepper", "cheese", "milk",
	"pasta", "pot", "water", "olive_oil", "garlic", "tomatoes",
	"lettuce", "vegetables", "cucumber", "dressing", "nuts",
	"bread", "ham", "herbs", "flour", "sugar", "vanilla", 
	"berries", "syrup", "onion", "mushrooms", "spinach"
]

# Ingredient display names
var ingredient_names = {
	"eggs": "🥚 Eggs",
	"pan": "🍳 Pan",
	"butter": "🧈 Butter",
	"salt": "🧂 Salt",
	"pepper": "🌶️ Pepper",
	"cheese": "🧀 Cheese",
	"milk": "🥛 Milk",
	"pasta": "🍜 Pasta",
	"pot": "🍲 Pot",
	"water": "💧 Water",
	"olive_oil": "🫒 Olive Oil",
	"garlic": "🧄 Garlic",
	"tomatoes": "🍅 Tomatoes",
	"lettuce": "🥬 Lettuce",
	"vegetables": "🥕 Mixed Vegetables",
	"cucumber": "🥒 Cucumber",
	"dressing": "🥗 Dressing",
	"nuts": "🥜 Nuts",
	"bread": "🍞 Bread",
	"ham": "🍖 Ham",
	"herbs": "🌿 Fresh Herbs",
	"flour": "🌾 Flour",
	"sugar": "🍯 Sugar",
	"vanilla": "🍦 Vanilla",
	"berries": "🫐 Berries",
	"syrup": "🍯 Maple Syrup",
	"onion": "🧅 Onion",
	"mushrooms": "🍄 Mushrooms",
	"spinach": "🥬 Spinach"
}

func _ready():
	_setup_scene()
	_create_recipe_buttons()
	_connect_signals()

func _setup_scene():
	# Fade in animation
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	_update_score_display()

func _update_score_display():
	score_label.text = "[center][b]Score: " + str(player_score) + "[/b][/center]"
	
	# Update initial cooking status
	cooking_status.text = "[center][b]Ready to Cook![/b]

Select a recipe from the left panel to get started.

Chad stands in the kitchen, nervous but determined to learn the ancient art of... not ordering takeout.[/center]"

func _connect_signals():
	back_button.pressed.connect(_on_back_pressed)

func _create_recipe_buttons():
	# Create buttons for each recipe
	for i in range(recipes.size()):
		var recipe = recipes[i]
		
		# Create recipe button
		var button = Button.new()
		button.text = recipe["name"]
		button.custom_minimum_size = Vector2(0, 60)
		button.add_theme_font_size_override("font_size", 18)
		button.add_theme_color_override("font_color", Color.WHITE)
		
		# Add to recipe list
		recipe_list.add_child(button)
		
		# Connect button signal
		button.pressed.connect(_on_recipe_selected.bind(i))
		
		# Add description label
		var desc_label = RichTextLabel.new()
		desc_label.custom_minimum_size = Vector2(0, 40)
		desc_label.bbcode_enabled = true
		desc_label.text = "[center][i]" + recipe["description"] + "[/i][/center]"
		desc_label.add_theme_font_size_override("font_size", 14)
		desc_label.add_theme_color_override("default_color", Color(0.8, 0.8, 0.8, 1))
		desc_label.fit_content = true
		desc_label.scroll_active = false
		
		recipe_list.add_child(desc_label)
		
		# Add spacer
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 15)
		recipe_list.add_child(spacer)

func _on_recipe_selected(recipe_index: int):
	if cooking_in_progress:
		return
	
	selected_recipe_index = recipe_index
	selected_recipe = recipes[recipe_index]
	current_mode = "ingredient_selection"
	
	# Show ingredient selection
	_show_ingredient_selection()

func _show_ingredient_selection():
	# Clear recipe list
	for child in recipe_list.get_children():
		if child.name != "Title" and child.name != "Subtitle" and child.name != "Spacer":
			child.queue_free()
	
	# Update title
	var title = recipe_list.get_node("Title")
	title.text = "[center][b]🛒 Choose Your Ingredients[/b][/center]"
	
	var subtitle = recipe_list.get_node("Subtitle")
	subtitle.text = "[center]Use your cooking knowledge to choose the right ingredients![/center]"
	
	# Add spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 15)
	recipe_list.add_child(spacer)
	
	# Create ingredient buttons
	ingredient_buttons.clear()
	selected_ingredients.clear()
	
	for ingredient in all_ingredients:
		var button = Button.new()
		button.text = ingredient_names.get(ingredient, ingredient)
		button.custom_minimum_size = Vector2(0, 40)
		button.add_theme_font_size_override("font_size", 14)
		button.add_theme_color_override("font_color", Color.WHITE)
		button.toggle_mode = true
		
		# Connect button signal
		button.pressed.connect(_on_ingredient_selected.bind(ingredient, button))
		
		recipe_list.add_child(button)
		ingredient_buttons.append(button)
	
	# Add cook button
	var cook_button = Button.new()
	cook_button.text = "🔥 Start Cooking!"
	cook_button.custom_minimum_size = Vector2(0, 60)
	cook_button.add_theme_font_size_override("font_size", 20)
	cook_button.add_theme_color_override("font_color", Color.WHITE)
	cook_button.add_theme_color_override("font_color_pressed", Color.BLACK)
	cook_button.pressed.connect(_start_cooking_with_ingredients)
	
	recipe_list.add_child(cook_button)
	
	# Update cooking status
	cooking_status.text = "[center][b]Ingredient Selection[/b]

Choose your ingredients wisely!

[i]Select ingredients from the left panel, then click 'Start Cooking!'[/i][/center]"

func _on_ingredient_selected(ingredient: String, button: Button):
	if ingredient in selected_ingredients:
		# Remove ingredient
		selected_ingredients.erase(ingredient)
		button.button_pressed = false
		button.add_theme_color_override("font_color", Color.WHITE)
	else:
		# Add ingredient
		selected_ingredients.append(ingredient)
		button.button_pressed = true
		button.add_theme_color_override("font_color", Color.YELLOW)
	
	# Update cooking status with current selection
	_update_ingredient_status()

func _update_ingredient_status():
	var selected_text = ""
	if selected_ingredients.size() > 0:
		selected_text = "[b]Selected:[/b] " + ", ".join(selected_ingredients) + "

"
	
	cooking_status.text = "[center][b]Ingredient Selection[/b]

" + selected_text + "
Choose your ingredients wisely!

[i]Select ingredients from the left panel, then click 'Start Cooking!'[/i][/center]"

func _start_cooking_with_ingredients():
	if cooking_in_progress:
		return
	
	cooking_in_progress = true
	current_mode = "cooking"
	
	# Calculate score
	var score = _calculate_score()
	player_score += score
	
	# Show cooking sequence
	_play_cooking_steps_with_score(score)

func _calculate_score():
	var score = 0
	var required_ingredients = selected_recipe["required"]
	var optional_ingredients = selected_recipe["optional"]
	var missing_required = []
	
	# Check for missing required ingredients
	for ingredient in required_ingredients:
		if ingredient not in selected_ingredients:
			missing_required.append(ingredient)
			score -= 30  # -30 for each missing required ingredient
	
	# If we have all required ingredients, give positive points
	if missing_required.size() == 0:
		# Check if player selected exactly the required ingredients (perfect score)
		var has_only_required = true
		for ingredient in selected_ingredients:
			if ingredient not in required_ingredients:
				has_only_required = false
				break
		
		if has_only_required and selected_ingredients.size() == required_ingredients.size():
			score += 50  # Perfect score: exactly the required ingredients
		else:
			# Check if extras are at least optional ingredients
			var has_invalid_extras = false
			for ingredient in selected_ingredients:
				if ingredient not in required_ingredients and ingredient not in optional_ingredients:
					has_invalid_extras = true
					break
			
			if not has_invalid_extras:
				score += 30  # Good score: all required + only valid optional ingredients
			else:
				score += 10  # Okay score: all required but some invalid extras
	
	return score

func _arrays_match(arr1: Array, arr2: Array) -> bool:
	if arr1.size() != arr2.size():
		return false
	
	for item in arr1:
		if item not in arr2:
			return false
	
	return true

func _play_cooking_steps_with_score(_score: int):
	# Update score display
	_update_score_display()
	
	# Simple cooking message without scoring details
	cooking_status.text = "[center][b]Cooking Time![/b]

Let's see how Chad does with cooking...

[i]Now starting the cooking process...[/i][/center]"
	
	# Wait a moment, then start cooking steps
	await get_tree().create_timer(2.0).timeout
	_play_cooking_steps(selected_recipe["steps"])

func _play_cooking_steps(steps: Array):
	for i in range(steps.size()):
		var step = steps[i]
		
		cooking_status.text = "[center][b]Cooking in Progress...[/b]

" + step + "

[i]Step " + str(i + 1) + " of " + str(steps.size()) + "[/i][/center]"
		
		# Wait 3 seconds before next step
		await get_tree().create_timer(3.0).timeout
	
	# Cooking complete
	_finish_cooking()

func _finish_cooking():
	cooking_status.text = "[center][b]🎉 Cooking Complete! 🎉[/b]

Chad has successfully made " + selected_recipe["name"] + "!

The transformation is real - from tech bro who lived on energy drinks to someone who can actually create food with thoughtful ingredient selection.

[b]Achievement Unlocked: Home Chef![/b]

[color=green]Click 'Cook Again' to try another recipe![/color][/center]"
	
	cooking_in_progress = false
	current_mode = "complete"
	
	# Add cook again button
	_create_cook_again_button()

func _create_cook_again_button():
	# Remove existing cook again button if any
	var existing_button = get_node_or_null("CookAgainButton")
	if existing_button:
		existing_button.queue_free()
	
	# Create new cook again button
	var cook_again_button = Button.new()
	cook_again_button.name = "CookAgainButton"
	cook_again_button.text = "🍳 Cook Again!"
	cook_again_button.position = Vector2(get_viewport().size.x / 2 - 100, get_viewport().size.y - 120)
	cook_again_button.size = Vector2(200, 50)
	cook_again_button.add_theme_font_size_override("font_size", 20)
	cook_again_button.add_theme_color_override("font_color", Color.WHITE)
	cook_again_button.add_theme_color_override("font_color_pressed", Color.BLACK)
	
	add_child(cook_again_button)
	cook_again_button.pressed.connect(_reset_cooking_scene)

func _reset_cooking_scene():
	# Remove cook again button
	var cook_again_button = get_node_or_null("CookAgainButton")
	if cook_again_button:
		cook_again_button.queue_free()
	
	# Reset variables
	selected_recipe_index = -1
	selected_recipe = {}
	selected_ingredients.clear()
	cooking_in_progress = false
	current_mode = "recipe_selection"
	ingredient_buttons.clear()
	
	# Clear recipe list and recreate initial state
	for child in recipe_list.get_children():
		if child.name != "Title" and child.name != "Subtitle" and child.name != "Spacer":
			child.queue_free()
	
	# Reset titles
	var title = recipe_list.get_node("Title")
	title.text = "[center][b]🍳 Chad's Cooking Adventure[/b][/center]"
	
	var subtitle = recipe_list.get_node("Subtitle")
	subtitle.text = "[center]Choose a recipe to start cooking![/center]"
	
	# Reset cooking status
	cooking_status.text = "[center][b]Ready to Cook![/b]

Select a recipe from the left panel to get started.

Chad stands in the kitchen, ready for another culinary adventure![/center]"
	
	# Recreate recipe buttons
	_create_recipe_buttons()

func _on_back_pressed():
	# Fade out and return to kitchen
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/kitchen_scene.tscn")

func _input(event):
	# Allow ESC to go back
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
