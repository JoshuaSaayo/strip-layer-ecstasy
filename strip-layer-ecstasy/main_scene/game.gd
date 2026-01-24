extends Control

@onready var dim: ColorRect = $CharacterStrip/Pause/Dim
@onready var pause: Control = $CharacterStrip/Pause
@onready var character_strip: Node2D = $CharacterStrip

var intro_started := false

func _ready() -> void:
	pause.visible = false
	dim.visible = false
	
	# Let flow_controller handle the dialogue
	# Remove any dialogue-related code from here

func _on_intro_dialogue_finished():
	character_strip.load_stripping_scene()

func _on_finish_dialogue_done():
	get_tree().change_scene_to_file(GameState.get_level()["scenes"]["lewd"])
