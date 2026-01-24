extends Control

@onready var new_game: Button = $NewGame
@onready var settings_btn: Button = $SettingsBtn
@onready var credits_btn: Button = $CreditsBtn
@onready var quit_btn: Button = $QuitBtn
@onready var logo: Sprite2D = $Logo
@onready var dim: ColorRect = $Dim
@onready var credits: Control = $Credits
@onready var quit: Control = $Quit
@onready var main_menu: Node2D = $main_menu

func _ready() -> void:
	new_game.visible = true
	settings_btn.visible = true
	credits_btn.visible = true
	quit_btn.visible = true
	logo.visible = true
	dim.visible = false
	credits.visible = false
	quit.visible = false

	play_menu_animation()
	
func play_menu_animation():
	# Track 0, animation name, loop = true
	main_menu.get_animation_state().set_animation("animation", true, 0)
	
func _on_new_game_pressed() -> void:
	print("=== MAIN MENU: New Game pressed ===")
	
	# Reset game state
	GameState.current_level = 0
	print("GameState level set to: ", GameState.current_level)
	
	# Change scene
	get_tree().change_scene_to_file("res://main_scene/game.tscn")
	print("Scene change requested")


func _on_credits_btn_pressed() -> void:
	new_game.visible = false
	settings_btn.visible = false
	credits_btn.visible = false
	quit_btn.visible = false
	logo.visible = false
	dim.visible = true
	credits.visible = true
	

func _on_pause_button_pressed() -> void:
	new_game.visible = true
	settings_btn.visible = true
	credits_btn.visible = true
	quit_btn.visible = true
	logo.visible = true
	dim.visible = false
	credits.visible = false


func _on_quit_btn_pressed() -> void:
	quit.visible = true


func _on_no_btn_pressed() -> void:
	quit.visible = false


func _on_yes_btn_pressed() -> void:
	get_tree().quit()
