extends TextureRect

var color = Options.colorbg


func _process(delta):
	color = Options.colorbg
	modulate = Color(color[0] + color[1] + color[2],color[4] + color[5] + color[6],color[8]+color[9]+color[10])
	if Options.scrollbg != "true":
		$AnimationPlayer.playback_speed = 0
	else:
		$AnimationPlayer.playback_speed = 13.05
