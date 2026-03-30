extends Node2D

@export var polyphony: int = 8

const NOTE_FREQS: Dictionary = {
	48: 130.81, 49: 138.59, 50: 146.83, 51: 155.56, 52: 164.81,
	53: 174.61, 54: 185.00, 55: 196.00, 56: 207.65, 57: 220.00,
	58: 233.08, 59: 246.94, 60: 261.63, 61: 277.18, 62: 293.66,
	63: 311.13, 64: 329.63, 65: 349.23, 66: 369.99, 67: 392.00,
	68: 415.30, 69: 440.00, 70: 466.16, 71: 493.88, 72: 523.25,
}

var _voices: Array[AudioStreamPlayer] = []
var _active_notes: Dictionary = {}
var _voice_idx: int = 0
var _release: float = 0.3

@onready var label: Label = $Label

func _ready() -> void:
	_build_voice_pool()
	if label:
		label.text = "PIANO"

func _build_voice_pool() -> void:
	for v in _voices:
		v.queue_free()
	_voices.clear()
	for i in polyphony:
		var player := AudioStreamPlayer.new()
		player.bus = "Instrument"
		add_child(player)
		_voices.append(player)

func play_note(note: int, velocity: float = 1.0) -> void:
	if note in _active_notes:
		stop_note(note)
	var vi = _voice_idx % polyphony
	_voice_idx += 1
	_active_notes[note] = vi
	_play_voice(vi, NOTE_FREQS.get(note, 440.0), velocity)

func _play_voice(vi: int, freq: float, vel: float) -> void:
	var player := _voices[vi]
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = 44100.0
	gen.buffer_length = 4.0
	player.stream = gen
	player.volume_db = linear_to_db(vel)
	player.play()
	await get_tree().process_frame
	var playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
	if not playback:
		return
	_synth_piano(playback, freq, vel)

func stop_note(note: int) -> void:
	if note not in _active_notes:
		return
	var vi = _active_notes[note]
	_active_notes.erase(note)
	var tween = create_tween()
	tween.tween_property(_voices[vi], "volume_db", -80.0, _release)
	tween.tween_callback(_voices[vi].stop)

func _synth_piano(playback: AudioStreamGeneratorPlayback, freq: float, vel: float) -> void:
	var sample_rate := 44100.0
	var frames := int(sample_rate * 3.0)
	var buf: PackedVector2Array = []
	buf.resize(frames)
	var phase := 0.0
	for i in frames:
		var t = i / sample_rate
		var envelope = exp(-t * 3.0) * vel
		var sample := 0.0
		for h in 6:
			var harmonic = h + 1.0
			var harm_env = exp(-t * (2.0 + h * 1.5))
			sample += sin(TAU * freq * harmonic * phase / freq) * harm_env / harmonic
		sample *= envelope * 0.4
		buf[i] = Vector2(sample, sample)
		phase += freq / sample_rate
	playback.push_buffer(buf)
