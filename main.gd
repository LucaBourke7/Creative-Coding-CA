extends Node2D

var instrument
var controller

func _ready() -> void:
	await get_tree().process_frame
	instrument = get_node_or_null("Instrument")
	controller = get_node_or_null("Controller")

	if controller and instrument:
		controller.note_on.connect(instrument.play_note)
		controller.note_off.connect(instrument.stop_note)
