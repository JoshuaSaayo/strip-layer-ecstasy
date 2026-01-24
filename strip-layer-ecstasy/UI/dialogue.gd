extends Control

@onready var text: Label = $Panel/DialogueText

var running := false
var lines: Array = []
var index: int = 0
var on_finish: Callable

func _ready():
	print("Dialogue instance created: ", self.name, " - ", self.get_instance_id())
	
func start(dialogue_lines: Array, finished_callback: Callable):
	lines = dialogue_lines
	index = 0
	on_finish = finished_callback
	running = true
	visible = true # Ensure it's shown
	show_line()

func show_line():
	if index >= lines.size():
		running = false
		if on_finish.is_valid():
			on_finish.call()
		return

	text.text = ""     # 🔥 clear first
	text.text = lines[index]
	index += 1

func _finish():
	running = false
	text.text = ""
	visible = false
	if on_finish.is_valid():
		on_finish.call()

func _on_next_pressed():
	if running:
		show_line()

func cleanup():
	running = false
	lines = []
	index = 0
	text.text = ""
	queue_free()

func _exit_tree():
	print("Dialogue instance removed: ", self.name, " - ", self.get_instance_id())
