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
	reset_ui()
	play_menu_animation()

func reset_ui():
	new_game.visible = true
	settings_btn.visible = true
	credits_btn.visible = true
	quit_btn.visible = true
	logo.visible = true
	dim.visible = false
	credits.visible = false
	quit.visible = false

func play_menu_animation():
	main_menu.get_animation_state().set_animation("animation", true, 0)

func _on_new_game_pressed() -> void:
	GameState.current_level = 0

	await Fade.fade_out_white()
	get_tree().change_scene_to_file("res://main_scene/game.tscn")
	await Fade.fade_in_white()

	FlowController.start_game()

func _on_credits_btn_pressed() -> void:
	toggle_ui(false)
	dim.visible = true
	credits.visible = true

func _on_pause_button_pressed() -> void:
	reset_ui()

func _on_quit_btn_pressed() -> void:
	quit.visible = true

func _on_no_btn_pressed() -> void:
	quit.visible = false

func _on_yes_btn_pressed() -> void:
	get_tree().quit()

func toggle_ui(show: bool):
	new_game.visible = show
	settings_btn.visible = show
	credits_btn.visible = show
	quit_btn.visible = show
	logo.visible = show
