extends Node

var current_dialogue = null

func _ready():
	start_intro_dialogue()

func start_intro_dialogue():
	var lvl = GameState.get_level()
	_show_dialogue(lvl["dialogue"]["intro"], start_stripping)

func start_stripping():
	# Clean up dialogue before scene change
	if current_dialogue and is_instance_valid(current_dialogue):
		current_dialogue.queue_free()
		current_dialogue = null
	
	var lvl = GameState.get_level()
	get_tree().change_scene_to_file(lvl["scenes"]["stripping"])

func start_finish_dialogue():
	var lvl = GameState.get_level()
	_show_dialogue(lvl["dialogue"]["finish"], start_lewd)

func start_lewd():
	# Clean up dialogue before scene change
	if current_dialogue and is_instance_valid(current_dialogue):
		current_dialogue.queue_free()
		current_dialogue = null
	
	var lvl = GameState.get_level()
	get_tree().change_scene_to_file(lvl["scenes"]["lewd"])

func _show_dialogue(lines: Array, callback: Callable):
	# Remove existing dialogue first
	if current_dialogue and is_instance_valid(current_dialogue):
		current_dialogue.queue_free()
		current_dialogue = null
	
	# Create new dialogue
	var dlg = preload("res://UI/dialogue.tscn").instantiate()
	add_child(dlg)
	current_dialogue = dlg
	
	# Pass the callback that includes cleanup
	dlg.start(lines, func():
		# Clean up dialogue when finished
		if current_dialogue and is_instance_valid(current_dialogue):
			current_dialogue.queue_free()
			current_dialogue = null
		# Then call the original callback
		callback.call()
	)
