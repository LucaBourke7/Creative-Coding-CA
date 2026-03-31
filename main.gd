extends Node2D

var instrument
var controller
var fx_rack

func _ready() -> void:
	await get_tree().process_frame
	instrument = get_node_or_null("Instrument")
	controller = get_node_or_null("Controller")
	fx_rack = get_node_or_null("FXRack")

	if controller and instrument:
		controller.note_on.connect(instrument.play_note)
		controller.note_off.connect(instrument.stop_note)

	if fx_rack:
			fx_rack.reverb_changed.connect(_on_reverb_changed)
			fx_rack.delay_changed.connect(_on_delay_changed)
			fx_rack.filter_changed.connect(_on_filter_changed)
			fx_rack.pitch_changed.connect(_on_pitch_changed)

func _get_effect(type) -> Object:
	var bus = AudioServer.get_bus_index("Instrument")
	for i in AudioServer.get_bus_effect_count(bus):
		var fx = AudioServer.get_bus_effect(bus, i)
		if is_instance_of(fx, type):
			return fx
	return null

func _on_reverb_changed(wet: float, room_size: float) -> void:
	var fx = _get_effect(AudioEffectReverb)
	if fx:
		fx.wet = wet
		fx.room_size = room_size

func _on_delay_changed(dry: float, wet: float, feedback: float) -> void:
	var fx = _get_effect(AudioEffectDelay)
	if fx:
		fx.dry = dry
		fx.tap1_level_db = wet
		fx.feedback_level_db = feedback

func _on_filter_changed(cutoff: float, resonance: float) -> void:
	var fx = _get_effect(AudioEffectFilter)
	if fx:
		fx.cutoff_hz = cutoff
		fx.resonance = resonance

func _on_pitch_changed(semitones: float) -> void:
	var fx = _get_effect(AudioEffectPitchShift)
	if fx:
		fx.pitch_scale = pow(2.0, semitones / 12.0)
