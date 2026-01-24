extends Node

@onready var bgm: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	add_child(bgm)
	bgm.bus = "Music"
	var stream = preload("res://UI/sounds/background_ost.wav")
	if stream:
		bgm.stream = stream
		print("[MusicManager] Background stream loaded OK")
	else:
		print("[MusicManager] ERROR: Failed to load background_ost.wav")

	# Optional: test volume
	bgm.volume_db = 0.0   # reset to default

func play_game_music():
	if not bgm:
		print("[MusicManager] ERROR: bgm is null!")
		return
	if not bgm.stream:
		print("[MusicManager] ERROR: No stream assigned!")
		return
	if bgm.playing:
		print("[MusicManager] Already playing — skipping")
		return
		
	bgm.play()
	print("[MusicManager] → BGM PLAY called")

func stop_game_music():
	if bgm and bgm.playing:
		bgm.stop()
		print("[MusicManager] → BGM STOP called")

func is_playing() -> bool:
	return bgm.playing if bgm else false
