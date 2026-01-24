extends CanvasLayer

@onready var rect: ColorRect = $ColorRect

const FADE_TIME := 0.4

func fade_in_white():
	rect.visible = true
	rect.modulate.a = 1.0

	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 0.0, FADE_TIME)
	await tween.finished
	rect.visible = false

func fade_out_white():
	rect.visible = true
	rect.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, FADE_TIME)
	await tween.finished
