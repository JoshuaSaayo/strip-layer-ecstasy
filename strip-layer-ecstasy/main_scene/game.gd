extends Node2D

@onready var dim: ColorRect = $Pause/Dim
@onready var pause: Control = $Pause

func _ready() -> void:
	pause.visible = false
	dim.visible = false

func _on_pause_button_pressed() -> void:
	pause.visible = true
	dim.visible = true

func _on_resume_btn_pressed() -> void:
	pause.visible = false
	dim.visible = false


func _on_main_menu_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/menu.tscn")
