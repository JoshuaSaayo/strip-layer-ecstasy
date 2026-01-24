extends Node

var current_dialogue = null
var current_stripping_scene = null
var game_started = false

func _ready():
	game_started = false

func start_game():
	if game_started: return
	game_started = true
	var first_lvl = GameState.get_level()  # Assumes level 1
	if not _validate_level(first_lvl): return
	get_tree().call_deferred("change_scene_to_file", first_lvl["scenes"]["stripping"])
	# ← New stripping scene's _ready() will auto-trigger intro (Step 3)

func cleanup():
	if is_instance_valid(current_dialogue):
		current_dialogue.queue_free()
		current_dialogue = null
	
	if is_instance_valid(current_stripping_scene):
		current_stripping_scene.queue_free()
		current_stripping_scene = null

func on_stripping_scene_ready(scene):
	cleanup()  # Clears any old dialogue/scene refs
	current_stripping_scene = scene
	await get_tree().process_frame  # Ensure scene is fully ready
	if current_stripping_scene.has_method("set_mode"):
		current_stripping_scene.set_mode(current_stripping_scene.Mode.INTRO)
	var lvl = GameState.get_level()
	_show_dialogue(lvl["dialogue"]["intro"], _on_intro_dialogue_finished)

func _validate_level(lvl: Dictionary) -> bool:
	if not lvl or not lvl.has("scenes") or not lvl.has("dialogue"):
		push_error("Invalid level data")
		return false
	return true

func _on_intro_dialogue_finished():
	if is_instance_valid(current_stripping_scene):
		if current_stripping_scene.has_method("set_mode"):
			current_stripping_scene.set_mode(current_stripping_scene.Mode.STRIPPING)
		
		if current_stripping_scene.has_signal("stripping_finished"):
			current_stripping_scene.stripping_finished.connect(_on_stripping_finished)

func _on_stripping_finished():
	_show_dialogue(GameState.get_level()["dialogue"]["finish"], _on_finish_dialogue_done)

func _on_finish_dialogue_done():
	var lewd_scene = GameState.get_level()["scenes"]["lewd"]

	await Fade.fade_out_white()
	cleanup()
	get_tree().change_scene_to_file(lewd_scene)
	await Fade.fade_in_white()

func _show_dialogue(lines: Array, callback: Callable):
	if is_instance_valid(current_stripping_scene):
		current_stripping_scene.set_process_input(false)
		current_stripping_scene.set_process(false)
	
	cleanup_dialogue()
	
	current_dialogue = preload("res://UI/dialogue.tscn").instantiate()
	get_tree().current_scene.add_child(current_dialogue)
	_bring_to_front(current_dialogue)
	
	current_dialogue.start(lines, func():
		cleanup_dialogue()
		callback.call()
	)

func cleanup_dialogue():
	if is_instance_valid(current_dialogue):
		current_dialogue.queue_free()
	current_dialogue = null

func _bring_to_front(node: Node):
	var parent = node.get_parent()
	if parent:
		parent.move_child(node, parent.get_child_count() - 1)
