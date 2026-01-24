extends Node

var current_dialogue = null
var current_stripping_scene = null
var game_started = false  # Make sure this is declared HERE at the top!

func _ready():
	print("=== FLOW_CONTROLLER: _ready() called ===")
	game_started = false  # Reset on start

func start_game():
	print("=== FLOW_CONTROLLER: start_game() called ===")
	
	if game_started:
		print("Game already started!")
		return
	
	game_started = true
	print("Setting game_started = true")
	
	# Reset any existing state
	cleanup()
	
	# Start the intro
	print("Calling start_intro_dialogue()")
	start_intro_dialogue()

func cleanup():
	# Clean up any existing scenes
	if current_dialogue and is_instance_valid(current_dialogue):
		current_dialogue.queue_free()
		current_dialogue = null
	
	if current_stripping_scene and is_instance_valid(current_stripping_scene):
		current_stripping_scene.queue_free()
		current_stripping_scene = null

func start_intro_dialogue():
	print("=== FLOW_CONTROLLER: start_intro_dialogue() called ===")
	
	var lvl = GameState.get_level()
	print("Level data retrieved: ", lvl)
	
	if not lvl or not lvl.has("scenes") or not lvl.has("dialogue"):
		push_error("Invalid level data")
		return
	
	# Load stripping scene
	var stripping_scene_path = lvl["scenes"]["stripping"]
	print("Loading stripping scene: ", stripping_scene_path)
	
	current_stripping_scene = load(stripping_scene_path).instantiate()
	
	# Add to the current scene
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.add_child(current_stripping_scene)
		print("Added stripping scene to: ", current_scene.name)
	
	# Wait for scene to be ready
	await get_tree().process_frame
	
	# Set to intro mode (pose1)
	if current_stripping_scene and current_stripping_scene.has_method("set_mode"):
		current_stripping_scene.set_mode(current_stripping_scene.Mode.INTRO)
		print("Set animation to intro mode")
	
	# Show intro dialogue
	print("Showing intro dialogue...")
	_show_dialogue(lvl["dialogue"]["intro"], _on_intro_dialogue_finished)

func _on_intro_dialogue_finished():
	print("Intro dialogue finished")
	
	# Switch to stripping mode
	if current_stripping_scene and is_instance_valid(current_stripping_scene):
		if current_stripping_scene.has_method("set_mode"):
			current_stripping_scene.set_mode(current_stripping_scene.Mode.STRIPPING)
			print("Set animation to stripping mode")
		
		# Connect to stripping_finished signal
		if current_stripping_scene.has_signal("stripping_finished"):
			current_stripping_scene.stripping_finished.connect(_on_stripping_finished)
			print("Connected to stripping_finished signal")

func _on_stripping_finished():
	print("Stripping finished")
	
	# Show finish dialogue
	var lvl = GameState.get_level()
	_show_dialogue(lvl["dialogue"]["finish"], _on_finish_dialogue_done)

func _on_finish_dialogue_done():
	print("Finish dialogue done")
	
	# Load lewd scene
	var lvl = GameState.get_level()
	var lewd_scene_path = lvl["scenes"]["lewd"]
	
	print("Loading lewd scene: ", lewd_scene_path)
	
	# Clean up before scene change
	cleanup()
	game_started = false
	
	get_tree().change_scene_to_file(lewd_scene_path)

func _show_dialogue(lines: Array, callback: Callable):
	print("Showing dialogue with ", lines.size(), " lines")
	
	# Remove existing dialogue
	if current_dialogue and is_instance_valid(current_dialogue):
		current_dialogue.queue_free()
		current_dialogue = null
	
	# Create new dialogue
	var dlg = preload("res://UI/dialogue.tscn").instantiate()
	
	# Add to current scene
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.add_child(dlg)
		print("Added dialogue to: ", current_scene.name)
	
	current_dialogue = dlg
	
	# Pass the callback
	dlg.start(lines, func():
		print("Dialogue callback executed")
		if current_dialogue and is_instance_valid(current_dialogue):
			current_dialogue.queue_free()
			current_dialogue = null
		callback.call()
	)
