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
	$ModeTabs.tabs_visible = false

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
