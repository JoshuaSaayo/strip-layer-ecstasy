extends Node2D

var stripping_instance: Node = null

func load_stripping_scene():
	clear_stripping()

	var lvl = GameState.get_level()
	var scene = load(lvl["scenes"]["stripping"])
	stripping_instance = scene.instantiate()
	add_child(stripping_instance)

	# CONNECT SIGNAL HERE
	if stripping_instance.has_signal("stripping_finished"):
		stripping_instance.stripping_finished.connect(_on_stripping_finished)

func _on_stripping_finished():
	get_parent().start_finish_dialogue()

func clear_stripping():
	if stripping_instance and is_instance_valid(stripping_instance):
		stripping_instance.queue_free()
		stripping_instance = null
