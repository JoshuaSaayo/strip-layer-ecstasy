extends Node2D

@onready var spine: Node2D = $SpineSprite
@onready var sfx_moan: AudioStreamPlayer = $SFX/SFXMoan
@onready var sfx_plaps: AudioStreamPlayer = $SFX/SFXPlaps
@onready var sfx_cum: AudioStreamPlayer = $SFX/SFXCum

# Character-specific moans (add more as needed)
var character_moans: Dictionary = {
	"yuri": [
		preload("res://lewds/lewd_assets/yuri_ls/sounds/yuri_moan1.wav"),
		preload("res://lewds/lewd_assets/yuri_ls/sounds/yuri_moan2.wav"),
		preload("res://lewds/lewd_assets/yuri_ls/sounds/yuri_moan3.wav")
	],
	"mei": [
		preload("res://lewds/lewd_assets/mei_ls/sounds/mei_moan1.wav"),  # ← Your 3 new Mei moans here
		preload("res://lewds/lewd_assets/mei_ls/sounds/mei_moan2.wav"),
		preload("res://lewds/lewd_assets/mei_ls/sounds/mei_moan3.wav")
	]
	# "terra": [ ... ]  ← Add later
}

@export var character: String = "yuri"  # ← Set in Inspector for each scene (yuri_ls.tscn = "yuri", mei_ls.tscn = "mei")

var moans = character_moans[character] as Array[AudioStream]

const LOOP_COUNT: int = 5
var loops_done: int = 0

func _ready():
	# Auto-select moans based on exported character
	if character_moans.has(character):
		moans = character_moans[character]
		print("Loaded ", moans.size(), " moans for character: ", character)
	else:
		push_error("Unknown character '", character, "' - add it to character_moans!")
		moans = []  # Empty fallback
	
	# Connect signals (unchanged)
	spine.animation_completed.connect(_on_animation_completed)
	spine.animation_event.connect(_on_animation_event)
	print("Signals connected. Starting lewdscene...")
	play_lewdscene()

# Rest of your functions unchanged...
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
			spine.get_animation_state().set_animation("climax", false, 0)
	elif anim_name == "climax":
		print("Climax finished!")
		if GameState.is_last_level():
			print("Last level → Ending credits")
			get_tree().change_scene_to_file("res://UI/ending_credits.tscn")
		else:
			print("Advancing to next level → Restarting flow")
			GameState.next_level()
			FlowController.start_game()

func _on_animation_event(spine_sprite: Object, animation_state: Object, track_entry: Object, event: Object):
	var event_name: String = event.get_data().get_event_name()
	print("Event triggered: ", event_name, " | Anim: ", track_entry.get_animation().get_name())
	match event_name.to_lower():
		"moan":
			if moans.size() > 0:
				var random_moan = moans.pick_random()
				sfx_moan.stream = random_moan
				sfx_moan.pitch_scale = randf_range(0.95, 1.05)
				sfx_moan.play()
				print("→ Played random ", character, " moan!")
			else:
				print("→ No moans loaded for ", character)
		"plap":
			sfx_plaps.play()  # ← Same plap for all (assigned in editor)
			print("→ Played plap!")
		"cum":
			sfx_cum.play()    # ← Same cum for all
			print("→ Played cum!")
		_:
			print("Unknown event: ", event_name)

func _exit_tree():
	if spine.animation_completed.is_connected(_on_animation_completed):
		spine.animation_completed.disconnect(_on_animation_completed)
	if spine.animation_event.is_connected(_on_animation_event):
		spine.animation_event.disconnect(_on_animation_event)
