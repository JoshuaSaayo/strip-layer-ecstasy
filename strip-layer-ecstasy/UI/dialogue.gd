extends Control

@onready var text: Label = $Panel/DialogueText
@onready var next_button: Button = $Next

var running := false
var lines: Array = []
var index: int = 0
var on_finish: Callable = Callable()

func _ready():
	print("=== DIALOGUE: _ready() called ===")
	
	# Make sure Next button is connected
	if next_button:
		next_button.pressed.connect(_on_next_pressed)
		print("Next button connected successfully")
	else:
		print("ERROR: NextButton not found!")
		# Try to find it by path
		next_button = get_node("Panel/NextButton")
		if next_button:
			print("Found NextButton manually")
			next_button.pressed.connect(_on_next_pressed)
	
	# Debug: Make sure we're visible and can receive input
	self.visible = true
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	self.process_mode = Node.PROCESS_MODE_INHERIT
	
	# Add keyboard support for testing
	print("Dialogue ready")

func start(dialogue_lines: Array, finished_callback: Callable = Callable()):
	print("=== DIALOGUE: start() called ===")
	print("Lines received: ", dialogue_lines)
	
	if running:
		print("Already running!")
		return

	running = true
	lines = dialogue_lines
	index = 0
	on_finish = finished_callback
	
	# Clear text and show first line
	text.text = ""
	
	# Make sure UI is visible
	self.visible = true
	
	# Show first line immediately
	show_line()

func show_line():
	print("=== DIALOGUE: show_line() called ===")
	print("Current index: ", index, "/", lines.size())
	
	if index >= lines.size():
		print("DIALOGUE FINISHED - All lines shown")
		running = false
		if on_finish.is_valid():
			print("Calling finish callback")
			on_finish.call()
		else:
			print("No finish callback")
		return
	
	# Get current line
	var current_line = lines[index]
	print("Showing line ", index, ": ", current_line)
	
	# Update text
	text.text = current_line
	
	# Move to next line for next click
	index += 1
	
	# If this was the last line, change button text
	if index >= lines.size():
		if next_button:
			next_button.text = "Finish"
		print("Last line shown - next click will finish")

func _on_next_pressed():
	print("=== DIALOGUE: NEXT BUTTON PRESSED ===")
	print("Button working! Current index before: ", index)
	show_line()

# Add keyboard support for testing
func _input(event):
	if not running:
		return
	
	# Space or Enter to advance
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			print("Keyboard advance triggered")
			_on_next_pressed()
	
	# Mouse click anywhere to advance
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Mouse click anywhere in dialogue")
		_on_next_pressed()

# Make sure dialogue is on top
func _enter_tree():
	# Use call_deferred to avoid timing issues during scene setup
	call_deferred("_bring_to_front")

func _bring_to_front():
	# Bring to front when added to scene
	var parent = get_parent()
	if parent:
		parent.move_child(self, parent.get_child_count() - 1)
		print("Dialogue moved to front")
