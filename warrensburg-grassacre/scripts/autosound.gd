extends Node

func play(stream: AudioStream, pitch: float = 1.0):
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.pitch_scale = pitch
	player.autoplay = true
	player.finished.connect(player.queue_free)
	get_tree().current_scene.add_child(player)
