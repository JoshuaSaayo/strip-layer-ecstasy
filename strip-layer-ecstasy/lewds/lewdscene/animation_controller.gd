extends Node2D

signal stripping_finished

@onready var spine: Node2D = $SpineSprite
@onready var click_spot_top: Area2D = $ClickSpotTop
@onready var click_spot_bottom: Area2D = $ClickSpotBottom
@onready var progress_bar: TextureProgressBar = $TextureProgressBar
@onready var layer_label: Label = $TextureProgressBar/Panel/Label

enum Mode { INTRO, STRIPPING, FINAL }
var current_mode: Mode = Mode.STRIPPING

var strip_level: int = 0
const MAX_LEVELS: int = 4
const CLICKS_NEEDED: int = 20
const DAMAGE_PER_CLICK: float = 100.0 / CLICKS_NEEDED
var is_stripping: bool = false

func _ready():
	FlowController.on_stripping_scene_ready(self)
	
	# ─── START BGM HERE ───
	if MusicManager:
		MusicManager.play_game_music()
		print("[AnimationController] Gameplay scene ready → BGM started")

	# Your existing connections...
	click_spot_top.input_event.connect(_on_click_spot.bind("top"))
	click_spot_bottom.input_event.connect(_on_click_spot.bind("bottom"))
	
	set_mode(Mode.STRIPPING)

func _exit_tree() -> void:
	if MusicManager:
		MusicManager.stop_game_music()
		print("[AnimationController] Stripping scene exited → BGM stopped")

func set_mode(mode: Mode):
	current_mode = mode
	
	match mode:
		Mode.INTRO:
			# Show pose1 for intro dialogue
			strip_level = 0
			play_pose(1)
			hide_interactive_elements()
			progress_bar.visible = false
			layer_label.visible = false
			
		Mode.STRIPPING:
			# Reset to pose1 and enable gameplay
			strip_level = 0
			reset_layer()
			update_ui()
			update_click_areas()
			progress_bar.visible = true
			layer_label.visible = true
			
		Mode.FINAL:
			# Show pose5 for finish dialogue
			play_pose(5)
			hide_interactive_elements()
			progress_bar.visible = false
			layer_label.visible = false
			# Signal that we're ready for finish dialogue
			stripping_finished.emit()

func play_pose(pose_number: int):
	var anim_name: String = "pose%d" % pose_number
	
	# Try different Spine node methods based on Spine2D 4.2 runtime
	if spine.has_method("get_animation_state"):
		spine.get_animation_state().set_animation(anim_name, true, 0)
	elif spine.has_method("set_animation"):
		# Direct method if available
		spine.set_animation(anim_name, true)
	elif spine.has_method("get_skeleton"):
		# Alternative Spine2D access
		spine.get_skeleton().set_animation(anim_name, true, 0)
	else:
		# Debug: Print available methods
		print("Spine node methods: ", spine.get_method_list())
		push_error("Cannot find animation method on spine node")
	
	is_stripping = false

func hide_interactive_elements():
	click_spot_top.visible = false
	click_spot_bottom.visible = false
	set_process_input(false)

func reset_layer():
	progress_bar.value = 100.0
	play_pose(strip_level + 1)
	is_stripping = false
	update_click_areas()
	set_process_input(true)

func update_click_areas():
	# Show/hide and reposition Area2D nodes based on current strip level
	match strip_level:
		0:  # First layer - click top
			click_spot_top.visible = true
			click_spot_bottom.visible = false
			
			
		1:  # Second layer - click mid
			click_spot_top.visible = false
			click_spot_bottom.visible = true
			
			
		2:  # Third layer - click bottom
			click_spot_top.visible = true
			click_spot_bottom.visible = false
			
			
		3:  # Final layer - any area
			click_spot_top.visible = false
			click_spot_bottom.visible = true

func play_idle():
	var anim_name: String = "pose%d" % (strip_level + 1)
	spine.get_animation_state().set_animation(anim_name, true, 0)
	is_stripping = false
	update_click_areas()

func trigger_strip():
	var anim_name: String = "pose%d_stripping" % (strip_level + 1)
	spine.get_animation_state().set_animation(anim_name, false, 0)
	is_stripping = true
	# Hide all click areas during stripping
	click_spot_top.visible = false
	click_spot_bottom.visible = false

func _on_click_spot(viewport: Node, event: InputEvent, shape_idx: int, area_type: String):
	if is_stripping:
		return
		
	# Handle both mouse click AND touchscreen tap
	var is_valid_press = false
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_valid_press = true
			
	elif event is InputEventScreenTouch:
		if event.pressed:  # true = finger down (tap start)
			is_valid_press = true
	
	if is_valid_press:
		# Optional: Different damage based on area type (you can expand later)
		var damage_multiplier = 1.0
		match area_type:
			"top":    damage_multiplier = 1.0
			"bottom": damage_multiplier = 1.2  # example: bottom more sensitive?
			_:        damage_multiplier = 1.0
		
		progress_bar.value -= DAMAGE_PER_CLICK * damage_multiplier
		update_ui()
		
		if progress_bar.value <= 0.0:
			trigger_strip()

func update_ui():
	layer_label.text = "Layer %d/4 %.0f%%" % [strip_level + 1, progress_bar.value]

func _on_spine_sprite_animation_completed(spine_sprite: Object, animation_state: Object, track_entry: Object) -> void:
	var anim_name: String = track_entry.get_animation().get_name()
	print("Animation ended: ", anim_name)
	
	if anim_name.contains("_stripping"):
		strip_level += 1
		
		if strip_level >= MAX_LEVELS:
			# All stripping done, switch to final pose
			set_mode(Mode.FINAL)
		else:
			reset_layer()


func _on_spine_sprite_animation_ended(spine_sprite: Object, animation_state: Object, track_entry: Object) -> void:
	pass # Replace with function body.
