extends Control

@onready var dim: ColorRect = $CharacterStrip/Pause/Dim
@onready var pause: Control = $CharacterStrip/Pause
@onready var character_strip: Node2D = $CharacterStrip

var intro_started := false

func _ready() -> void:
	print("=== GAME.TSCN: _ready() called ===")
	
	pause.visible = false
	dim.visible = false
	
	# Wait a frame
	await get_tree().process_frame
	print("GAME.TSCN: Frame processed, calling FlowController.start_game()")
	
	# Call FlowController
	if has_node("/root/FlowController"):
		print("FlowController found, calling start_game()")
		FlowController.start_game()
	else:
		print("ERROR: FlowController not found!")


func _on_intro_dialogue_finished():
	character_strip.load_stripping_scene()
