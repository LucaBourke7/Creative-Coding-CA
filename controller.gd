extends Node2D

signal note_on(note: int, velocity: float)
signal note_off(note: int)

const KEY_MAP := {
	KEY_A: 60, KEY_W: 61, KEY_S: 62, KEY_E: 63, KEY_D: 64,
	KEY_F: 65, KEY_T: 66, KEY_G: 67, KEY_Y: 68, KEY_H: 69,
	KEY_U: 70, KEY_J: 71, KEY_K: 72, KEY_O: 73, KEY_L: 74,
	KEY_P: 75, KEY_SEMICOLON: 76,
}

const NOTE_NAMES := ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

var _pressed_keys: Dictionary = {}
var _octave_offset: int = 0
var _note_label: Label

@onready var piano_container: HBoxContainer = $ModeTabs/Piano/Keys

func _ready() -> void:
	_build_piano()
	$ModeTabs.tabs_visible = false

func _build_piano() -> void:
	if not piano_container:
		return

	var piano_tab = $ModeTabs/Piano

	var oct_label := Label.new()
	oct_label.text = "Octave: 0"
	oct_label.custom_minimum_size = Vector2(90, 30)
	oct_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var oct_down := Button.new()
	oct_down.text = "◀ Oct"
	oct_down.custom_minimum_size = Vector2(80, 30)
	oct_down.pressed.connect(func():
		_octave_offset = max(-3, _octave_offset - 1)
		oct_label.text = "Octave: %d" % _octave_offset
	)

	var oct_up := Button.new()
	oct_up.text = "Oct ▶"
	oct_up.custom_minimum_size = Vector2(80, 30)
	oct_up.pressed.connect(func():
		_octave_offset = min(3, _octave_offset + 1)
		oct_label.text = "Octave: %d" % _octave_offset
	)

	var octave_row := HBoxContainer.new()
	octave_row.alignment = BoxContainer.ALIGNMENT_CENTER
	octave_row.add_child(oct_down)
	octave_row.add_child(oct_label)
	octave_row.add_child(oct_up)
	piano_tab.add_child(octave_row)
	piano_tab.move_child(octave_row, 0)

	var white_notes := [0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 17, 19, 21, 23]
	for offset in white_notes:
		var note = 60 + offset
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(36, 100)

		var style := StyleBoxFlat.new()
		style.bg_color = Color.WHITE
		style.border_color = Color(0.5, 0.5, 0.5)
		style.set_border_width_all(1)
		btn.add_theme_stylebox_override("normal", style)

		var hover_style := style.duplicate() as StyleBoxFlat
		hover_style.bg_color = Color(0.8, 1.0, 0.9)
		btn.add_theme_stylebox_override("hover", hover_style)

		var pressed_style := style.duplicate() as StyleBoxFlat
		pressed_style.bg_color = Color(0.3, 1.0, 0.6)
		btn.add_theme_stylebox_override("pressed", pressed_style)

		btn.button_down.connect(_on_piano_key_down.bind(note))
		btn.button_up.connect(_on_piano_key_up.bind(note))
		piano_container.add_child(btn)

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key = event.keycode
	if not key in KEY_MAP:
		return
	var note = KEY_MAP[key] + _octave_offset * 12
	if event.pressed and not event.echo:
		if key not in _pressed_keys:
			_pressed_keys[key] = true
			emit_signal("note_on", note, 0.8)
	elif not event.pressed:
		_pressed_keys.erase(key)
		emit_signal("note_off", note)
		
func _on_piano_key_down(note: int) -> void:
	emit_signal("note_on", note + _octave_offset * 12, 0.9)

func _on_piano_key_up(note: int) -> void:
	emit_signal("note_off", note + _octave_offset * 12)
