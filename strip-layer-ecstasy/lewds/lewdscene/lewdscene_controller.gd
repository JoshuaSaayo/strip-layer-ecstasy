extends Node2D

@onready var spine: Node2D = $SpineSprite
@onready var sfx_moan: AudioStreamPlayer = $SFX/SFXMoan
@onready var sfx_plaps: AudioStreamPlayer = $SFX/SFXPlaps
@onready var sfx_cum: AudioStreamPlayer = $SFX/SFXCum

var moans = [
	preload("res://lewds/lewd_assets/yuri_ls/sounds/yuri_moan1.wav"),
	preload("res://lewds/lewd_assets/yuri_ls/sounds/yuri_moan2.wav"),
	preload("res://lewds/lewd_assets/yuri_ls/sounds/yuri_moan3.wav")
]

const LOOP_COUNT: int = 5
var loops_done: int = 0

func _ready():
	# Connect in code (safer than editor for typed signals)
	spine.animation_completed.connect(_on_animation_completed)
	spine.animation_event.connect(_on_animation_event)
	
	print("Signals connected. Starting lewdscene...")
	play_lewdscene()

func play_lewdscene():
	spine.get_animation_state().set_animation("lewdscene", true, 0)

func _on_animation_completed(spine_sprite: Object, animation_state: Object, track_entry: Object):
	var anim_name = track_entry.get_animation().get_name()
	print("Animation completed: ", anim_name)
	
	if anim_name == "lewdscene":
		loops_done += 1
		print("Lewd loop completed: ", loops_done, "/", LOOP_COUNT)
		
		if loops_done >= LOOP_COUNT:
			print("All loops done → Starting climax!")
			spine.get_animation_state().set_animation("climax", false, 0)  # false = no loop
	
	elif anim_name == "climax":
		if GameState.is_last_level():
			get_tree().change_scene_to_file("res://UI/ending_credits.tscn")
		else:
			GameState.next_level()
			get_tree().change_scene_to_file("res://core/flow_controller.tscn")

func _on_animation_event(spine_sprite: Object, animation_state: Object, track_entry: Object, event: Object):
	# Correct for SpineEvent in official runtime
	var event_name: String = event.get_data().get_event_name()
	
	print("Event triggered: ", event_name, " | Anim: ", track_entry.get_animation().get_name())
	
	match event_name.to_lower():
		"moan":
			var random_moan = moans.pick_random()
			sfx_moan.stream = random_moan
			sfx_moan.pitch_scale = randf_range(0.95, 1.05)
			sfx_moan.play()
			print("→ Played random moan!")
		"plaps":
			sfx_plaps.play()
			print("→ Played plap!")
		"cum":
			sfx_cum.play()
			print("→ Played cum!")
		_:
			print("Unknown event: ", event_name)

func _exit_tree():
	if spine.animation_completed.is_connected(_on_animation_completed):
		spine.animation_completed.disconnect(_on_animation_completed)
	if spine.animation_event.is_connected(_on_animation_event):
		spine.animation_event.disconnect(_on_animation_event)
