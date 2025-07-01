extends Node2D
class_name SupportingCharacters

var characters: Dictionary = {}

func _ready():
	_initialize_characters()

func _initialize_characters():
	characters["Kyle"] = {
		"name": "Kyle",
		"personality_traits": [
			"Says 'diamond hands' unironically",
			"Has 47 different crypto wallets", 
			"Microwaves fish in the office microwave",
			"Genuinely thinks NFTs will come back"
		],
		"catchphrases": [
			"This is bullish for farming, bro",
			"Have you considered tokenizing your vegetables?",
			"My portfolio is down 90% but I'm still HODLing",
			"Web3 agriculture is the future, dude"
		],
		"relationship_level": 60,
		"character_arc": "Starts supportive but becomes jealous of protagonist's growth"
	}
	
	characters["Harrison"] = {
		"name": "Harrison",
		"personality_traits": [
			"4am cold showers and meditation",
			"Has a morning routine with 47 steps",
			"Reads self-help books while walking on treadmill desk",
			"Unironically calls himself a 'lifestyle entrepreneur'"
		],
		"catchphrases": [
			"You're leaving money on the table, bro",
			"This farming thing doesn't scale",
			"What's your 5-year growth strategy?",
			"I'm disrupting the disruption industry"
		],
		"relationship_level": 65,
		"character_arc": "Initially dismissive, eventually asks for farming advice"
	}
	
	characters["Marcus"] = {
		"name": "Marcus",
		"personality_traits": [
			"Owns exactly 100 items (counts them daily)",
			"Only wears identical white t-shirts",
			"Has strong opinions about which apps to delete",
			"Paradoxically very stressed about being minimalist"
		],
		"catchphrases": [
			"Do you really NEED that shovel?",
			"I've reduced my possessions but not my anxiety",
			"Plants are just clutter that grows",
			"Have you tried a digital garden instead?"
		],
		"relationship_level": 55,
		"character_arc": "Realizes minimalism without meaning is just emptiness"
	}
	
	characters["Sandra"] = {
		"name": "Sandra",
		"age": 67,
		"personality_traits": [
			"Always smells like rosemary and lavender",
			"Has a garden that defies San Francisco weather",
			"Speaks in gentle metaphors about growth",
			"Mysteriously knows exactly what you need to hear"
		],
		"wisdom_quotes": [
			"Plants teach us that growth happens slowly, then all at once",
			"You can't harvest what you don't plant, sweetie",
			"The soil of the heart needs tending too",
			"Sometimes the best fertilizer is tears"
		],
		"relationship_level": 0,
		"character_arc": "Mentor figure who guides protagonist's transformation"
	}
	
	characters["Victor"] = {
		"name": "Victor",
		"personality_traits": [
			"Still believes the startup would have worked",
			"Wears Patagonia vests exclusively", 
			"Name-drops VCs like old friends",
			"Has strong opinions about 'product-market fit'"
		],
		"bitter_quotes": [
			"You're throwing away everything we built",
			"This farming thing is just another pivot",
			"Remember when you cared about changing the world?",
			"I'll send you my Series A deck when you come to your senses"
		],
		"relationship_level": 40,
		"character_arc": "Represents the past life protagonist is leaving behind"
	}
	
	characters["Dr_Chen"] = {
		"name": "Dr. Patricia Chen",
		"personality_traits": [
			"Never judges, always listens",
			"Has plants in her office (foreshadowing!)",
			"Asks the questions protagonist didn't know they needed",
			"Somehow makes therapy feel like self-discovery"
		],
		"therapeutic_insights": [
			"What would it look like to succeed without burning out?",
			"When did you last feel proud of something you created?",
			"What would 12-year-old you think of your life now?",
			"Growth isn't always about going faster"
		],
		"relationship_level": 0,
		"character_arc": "Professional guide for emotional growth and self-reflection"
	}

func get_character_data(character_name: String) -> Dictionary:
	return characters.get(character_name, {})

func get_character_dialogue(character_name: String, context: String) -> String:
	match character_name:
		"Kyle":
			return _get_crypto_kyle_dialogue(context)
		"Harrison":
			return _get_hustle_harrison_dialogue(context)
		"Marcus":
			return _get_minimalist_marcus_dialogue(context)
		"Sandra":
			return _get_sage_sandra_dialogue(context)
		"Victor":
			return _get_venture_victor_dialogue(context)
		"Dr_Chen":
			return _get_dr_feelings_dialogue(context)
		_:
			return "Generic dialogue for unknown character"

func _get_crypto_kyle_dialogue(context: String) -> String:
	var kyle_data = characters["Kyle"]
	match context:
		"farming_decision":
			return "Bro, have you considered DeFi farming instead? The yields are insane!"
		"therapy":
			return "Therapy is just mental health coaching, and honestly, pretty bullish"
		"success":
			return "Your tomatoes are mooning, dude! This is huge!"
		_:
			var phrases = kyle_data["catchphrases"]
			return phrases[randi() % phrases.size()]

func _get_hustle_harrison_dialogue(context: String) -> String:
	var harrison_data = characters["Harrison"]
	match context:
		"farming_decision":
			return "What's your customer acquisition strategy for vegetables?"
		"burnout":
			return "Have you tried optimizing your sleep stack and morning routine?"
		"success":
			return "Okay, I see the metrics. Teach me your farming funnel."
		_:
			var phrases = harrison_data["catchphrases"]
			return phrases[randi() % phrases.size()]

func _get_minimalist_marcus_dialogue(context: String) -> String:
	var marcus_data = characters["Marcus"]
	match context:
		"farming_decision":
			return "Do you really need 47 different vegetables? I grow one type of lettuce."
		"tools":
			return "Why do you have so many gardening tools? I use one spoon for everything."
		"success":
			return "Your garden has achieved the perfect balance of necessary and sufficient."
		_:
			var phrases = marcus_data["catchphrases"]
			return phrases[randi() % phrases.size()]

func _get_sage_sandra_dialogue(context: String) -> String:
	var sandra_data = characters["Sandra"]
	match context:
		"first_meeting":
			return "I see you looking at my garden, dear. Plants sense when someone needs grounding."
		"cooking_failure":
			return "Burnt food is just love that got a little too excited, sweetie."
		"emotional_growth":
			return "You're growing roots now, not just chasing the sun."
		_:
			var quotes = sandra_data["wisdom_quotes"]
			return quotes[randi() % quotes.size()]

func _get_venture_victor_dialogue(context: String) -> String:
	var victor_data = characters["Victor"]
	match context:
		"farming_announcement":
			return "This is the worst pivot in startup history. What's your exit strategy?"
		"reconciliation":
			return "Maybe... maybe there's more than one way to build something meaningful."
		"dinner_party":
			return "This meal has better product-market fit than our app ever did."
		_:
			var quotes = victor_data["bitter_quotes"]
			return quotes[randi() % quotes.size()]

func _get_dr_feelings_dialogue(context: String) -> String:
	var dr_data = characters["Dr_Chen"]
	match context:
		"first_session":
			return "Tell me about a time you felt truly satisfied with your work."
		"breakthrough":
			return "You're learning that success doesn't have to feel like survival."
		"integration":
			return "How does it feel to create something that grows rather than scales?"
		_:
			var insights = dr_data["therapeutic_insights"]
			return insights[randi() % insights.size()]
