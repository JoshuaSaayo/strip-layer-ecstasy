extends Node

var current_level: int = 0
var game_data: Dictionary = {}

func _ready():
	load_game_data()

func load_game_data():
	var file = FileAccess.open("res://dialogues/dialogues.json", FileAccess.READ)
	if file == null:
		push_error("game_data.json not found!")
		return

	var parsed = JSON.parse_string(file.get_as_text())
	if parsed == null:
		push_error("JSON parse failed!")
		return

	game_data = parsed

func get_level() -> Dictionary:
	if not game_data.has("levels"):
		push_error("game_data missing 'levels'")
		return {}

	if current_level >= game_data["levels"].size():
		push_error("Invalid level index: %d" % current_level)
		return {}

	return game_data["levels"][current_level]

func next_level():
	current_level += 1

func is_last_level() -> bool:
	return current_level >= game_data["levels"].size() - 1
