extends Node2D

# Signals sent to Main.gd when a note is pressed or released
signal note_on(note: int, velocity: float)
signal note_off(note: int)

const KEY_MAP := { # Maps keyboard keys to MIDI note numbers
	KEY_A: 60, KEY_W: 61, KEY_S: 62, KEY_E: 63, KEY_D: 64,
	KEY_F: 65, KEY_T: 66, KEY_G: 67, KEY_Y: 68, KEY_H: 69,
	KEY_U: 70, KEY_J: 71, KEY_K: 72, KEY_O: 73, KEY_L: 74,
	KEY_P: 75, KEY_SEMICOLON: 76,
}

const NOTE_NAMES := ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"] # All 12 notes in an octave

var _pressed_keys: Dictionary = {} # Tracks which keys are held down so notes don't trigger twice
var _octave_offset: int = 0        # How many octaves up or down we have shifted
var _note_label: Label             # The label that shows the note name on screen

@onready var piano_container: HBoxContainer = $ModeTabs/Piano/Keys

func _ready() -> void:
	_build_piano()
	_build_note_label()
	$ModeTabs.tabs_visible = false # Hides the tab bar since we only have one tab

func _build_note_label() -> void: # Creates the note name display in the bottom area
	var bg := Panel.new() # Dark background box behind the note name
	bg.position = Vector2(217, 160)
	bg.size = Vector2(120, 80)
	add_child(bg)
	_note_label = Label.new()
	_note_label.text = ""
	_note_label.position = Vector2(235, 150)
	_note_label.add_theme_font_size_override("font_size", 64)
	_note_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.6))
	add_child(_note_label)

func _build_piano() -> void: # Builds the piano keys and octave buttons in code
	if not piano_container:
		return
	var piano_tab = $ModeTabs/Piano

	# Octave buttons let you shift all notes up or down by an octave
	var oct_label := Label.new()
	oct_label.text = "Octave: 0"
	oct_label.custom_minimum_size = Vector2(90, 30)
	oct_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var oct_down := Button.new()
	oct_down.text = "◀ Oct"
	oct_down.custom_minimum_size = Vector2(80, 30)
	oct_down.pressed.connect(func():
		_octave_offset = max(-3, _octave_offset - 1) # Minimum octave is -3
		oct_label.text = "Octave: %d" % _octave_offset
	)

	var oct_up := Button.new()
	oct_up.text = "Oct ▶"
	oct_up.custom_minimum_size = Vector2(80, 30)
	oct_up.pressed.connect(func():
		_octave_offset = min(3, _octave_offset + 1) # Maximum octave is +3
		oct_label.text = "Octave: %d" % _octave_offset
	)

	var octave_row := HBoxContainer.new()
	octave_row.alignment = BoxContainer.ALIGNMENT_CENTER
	octave_row.add_child(oct_down)
	octave_row.add_child(oct_label)
	octave_row.add_child(oct_up)
	piano_tab.add_child(octave_row)
	piano_tab.move_child(octave_row, 0) # Move octave row to the top

	var white_notes := [0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 17, 19, 21, 23] # Skips black keys
	for offset in white_notes:
		var note = 60 + offset # 60 is middle C
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(36, 100)

		var style := StyleBoxFlat.new() # White key style
		style.bg_color = Color.WHITE
		style.border_color = Color(0.5, 0.5, 0.5)
		style.set_border_width_all(1)
		btn.add_theme_stylebox_override("normal", style)

		var hover_style := style.duplicate() as StyleBoxFlat # Light green on hover
		hover_style.bg_color = Color(0.8, 1.0, 0.9)
		btn.add_theme_stylebox_override("hover", hover_style)

		var pressed_style := style.duplicate() as StyleBoxFlat # Bright green when pressed
		pressed_style.bg_color = Color(0.3, 1.0, 0.6)
		btn.add_theme_stylebox_override("pressed", pressed_style)

		btn.button_down.connect(_on_piano_key_down.bind(note))
		btn.button_up.connect(_on_piano_key_up.bind(note))
		piano_container.add_child(btn)

func _get_note_name(note: int) -> String: # Converts a note number to a name like "C4" or "F#3"
	var note_name = NOTE_NAMES[note % 12]
	var octave = (note / 12.0) - 1
	return "%s%d" % [note_name, octave]

func _unhandled_input(event: InputEvent) -> void: # Listens for keyboard presses
	if not event is InputEventKey:
		return
	var key = event.keycode
	if not key in KEY_MAP: # Ignore keys that aren't piano keys
		return
	var note = KEY_MAP[key] + _octave_offset * 12 # Apply octave shift to the note
	if event.pressed and not event.echo:
		if key not in _pressed_keys: # Only trigger once even if key is held
			_pressed_keys[key] = true
			if _note_label:
				_note_label.text = _get_note_name(note) # Show the note name on screen
			emit_signal("note_on", note, 0.8)
	elif not event.pressed:
		_pressed_keys.erase(key)
		if _pressed_keys.is_empty() and _note_label:
			_note_label.text = "" # Clear the label when no keys are held
		emit_signal("note_off", note)

func _on_piano_key_down(note: int) -> void: # Fires when a piano key is clicked with the mouse
	if _note_label:
		_note_label.text = _get_note_name(note + _octave_offset * 12)
	emit_signal("note_on", note + _octave_offset * 12, 0.9)

func _on_piano_key_up(note: int) -> void: # Fires when a piano key is released with the mouse
	if _note_label:
		_note_label.text = ""
	emit_signal("note_off", note + _octave_offset * 12)
