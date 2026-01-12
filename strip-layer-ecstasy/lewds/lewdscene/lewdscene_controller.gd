extends Node2D

@onready var spine: SpineSprite = $SpineSprite
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
	spine.animation_completed.connect(_on_lewd_loop_completed)
	# spine.animation_event.connect(_on_animation_event)  # If connected in editor, skip here
	play_lewdscene()

func play_lewdscene():
	spine.get_animation_state().set_animation("lewdscene", true, 0)  # loop = true

func _on_lewd_loop_completed(track_index: int, track_entry, loop_count: int):
	if track_entry.get_animation().get_name() == "lewdscene":
		loops_done += 1
		print("Lewd loop completed: ", loops_done, "/", LOOP_COUNT)
		
		if loops_done >= LOOP_COUNT:
			if spine.animation_completed.is_connected(_on_lewd_loop_completed):
				spine.animation_completed.disconnect(_on_lewd_loop_completed)
			spine.get_animation_state().set_animation("climax", false, 0)
			print("Climax triggered!")

# Your event handler (rename for clarity if you want)
func _on_spine_sprite_animation_event(spine_sprite: Object, animation_state: Object, track_entry: Object, event: Object) -> void:
	var event_name: String = event.get_name()  # ← FIXED HERE! Use get_name()
	
	print("Event triggered: ", event_name)  # Debug - should now print correctly
	
	match event_name.to_lower():
		"moan":
			var random_moan = moans.pick_random()
			sfx_moan.stream = random_moan
			sfx_moan.pitch_scale = randf_range(0.95, 1.05)
			sfx_moan.play()
		"plap":
			sfx_plaps.play()
		"cum":
			sfx_cum.play()
		_:
			print("Unknown event: ", event_name)

# Remove this entire function — duplicate of the one above
# func _on_spine_sprite_animation_completed(...): ...

# Clean up (optional but good)
func _exit_tree():
	if spine.animation_completed.is_connected(_on_lewd_loop_completed):
		spine.animation_completed.disconnect(_on_lewd_loop_completed)
