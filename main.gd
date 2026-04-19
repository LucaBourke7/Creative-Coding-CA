extends Node

var instrument
var controller
var fx_rack

func _ready() -> void:
	await get_tree().process_frame # Wait one frame so all nodes are ready before we try to find them
	instrument = get_node_or_null("Instrument") # Find the Instrument node, returns null if not found
	controller = get_node_or_null("Controller") # Find the Controller node, returns null if not found
	fx_rack    = get_node_or_null("FXRack")     # Find the FXRack node, returns null if not found

	if controller and instrument:
		controller.note_on.connect(instrument.play_note)  # When a key is pressed, play the note
		controller.note_off.connect(instrument.stop_note) # When a key is released, stop the note

	if fx_rack: # Only connect if FXRack exists
		fx_rack.reverb_changed.connect(_on_reverb_changed)  # When reverb slider moves, call _on_reverb_changed
		fx_rack.delay_changed.connect(_on_delay_changed)    # When delay slider moves, call _on_delay_changed
		fx_rack.filter_changed.connect(_on_filter_changed)  # When filter slider moves, call _on_filter_changed
		fx_rack.pitch_changed.connect(_on_pitch_changed)    # When pitch slider moves, call _on_pitch_changed

func _get_effect(type) -> Object: # Searches the Instrument audio bus for a specific effect
	var bus = AudioServer.get_bus_index("Instrument") # Get the index of the Instrument bus
	for i in AudioServer.get_bus_effect_count(bus):   # Loop through every effect on that bus
		var fx = AudioServer.get_bus_effect(bus, i)   # Get each effect one by one
		if is_instance_of(fx, type):                  # Check if it matches the type we want
			return fx                                  # Return it if found
	return null                                        # Return null if not found

func _on_reverb_changed(wet: float, room_size: float) -> void: # Updates reverb when slider moves
	var fx = _get_effect(AudioEffectReverb)
	if fx:
		fx.wet = wet
		fx.room_size = room_size

func _on_delay_changed(dry: float, wet: float, feedback: float) -> void: # Updates delay when slider moves
	var fx = _get_effect(AudioEffectDelay)
	if fx:
		fx.dry = dry
		fx.tap1_level_db = wet
		fx.feedback_level_db = feedback

func _on_filter_changed(cutoff: float, resonance: float) -> void: # Updates filter when slider moves
	var fx = _get_effect(AudioEffectFilter)
	if fx:
		fx.cutoff_hz = cutoff
		fx.resonance = resonance

func _on_pitch_changed(semitones: float) -> void: # Updates pitch when slider moves
	var fx = _get_effect(AudioEffectPitchShift)
	if fx:
		fx.pitch_scale = pow(2.0, semitones / 12.0)
