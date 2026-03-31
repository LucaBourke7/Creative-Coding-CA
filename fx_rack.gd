extends Node2D

signal reverb_changed(wet: float, room_size: float)
signal delay_changed(dry: float, wet: float, feedback: float)
signal filter_changed(cutoff: float, resonance: float)
signal pitch_changed(semitones: float)

const REVERB_PARAMS := [
	{"name": "Wet",       "min": 0.0,   "max": 1.0,     "default": 0.3},
	{"name": "Room",      "min": 0.0,   "max": 1.0,     "default": 0.5},
]
const DELAY_PARAMS := [
	{"name": "Dry",       "min": 0.0,   "max": 1.0,     "default": 1.0},
	{"name": "Wet",       "min": -60.0, "max": 0.0,     "default": -10.0},
	{"name": "Feedback",  "min": -80.0, "max": 0.0,     "default": -20.0},
]
const FILTER_PARAMS := [
	{"name": "Cutoff",    "min": 20.0,  "max": 20000.0, "default": 5000.0},
	{"name": "Resonance", "min": 0.0,   "max": 1.0,     "default": 0.2},
]
const PITCH_PARAMS := [
	{"name": "Pitch",     "min": -12.0, "max": 12.0,    "default": 0.0},
]

var _reverb_values := [0.3, 0.5]
var _delay_values  := [1.0, -10.0, -20.0]
var _filter_values := [5000.0, 0.2]

@onready var container: VBoxContainer = $Container

func _ready() -> void:
	_build_section("REVERB",      REVERB_PARAMS, _on_reverb_slider)
	_build_section("DELAY",       DELAY_PARAMS,  _on_delay_slider)
	_build_section("FILTER",      FILTER_PARAMS, _on_filter_slider)
	_build_section("PITCH SHIFT", PITCH_PARAMS,  _on_pitch_slider)

func _build_section(title: String, params: Array, callback: Callable) -> void:
	if not container:
		return

	var header := Label.new()
	header.text = "── %s ──" % title
	header.add_theme_color_override("font_color", Color(0.3, 1.0, 0.6))
	container.add_child(header)

	for i in params.size():
		var lbl := Label.new()
		lbl.text = params[i]["name"]
		lbl.custom_minimum_size = Vector2(80, 0)

		var slider := HSlider.new()
		slider.min_value = params[i]["min"]
		slider.max_value = params[i]["max"]
		slider.value = params[i]["default"]
		slider.custom_minimum_size = Vector2(150, 0)
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var val_label := Label.new()
		val_label.text = "%.2f" % params[i]["default"]
		val_label.custom_minimum_size = Vector2(50, 0)

		slider.value_changed.connect(func(v):
			val_label.text = "%.2f" % v
			callback.call(i, v)
		)

		var row := HBoxContainer.new()
		row.add_child(lbl)
		row.add_child(slider)
		row.add_child(val_label)
		container.add_child(row)

func _on_reverb_slider(idx: int, value: float) -> void:
	_reverb_values[idx] = value
	emit_signal("reverb_changed", _reverb_values[0], _reverb_values[1])

func _on_delay_slider(idx: int, value: float) -> void:
	_delay_values[idx] = value
	emit_signal("delay_changed", _delay_values[0], _delay_values[1], _delay_values[2])

func _on_filter_slider(idx: int, value: float) -> void:
	_filter_values[idx] = value
	emit_signal("filter_changed", _filter_values[0], _filter_values[1])

func _on_pitch_slider(_idx: int, value: float) -> void:
	emit_signal("pitch_changed", value)
