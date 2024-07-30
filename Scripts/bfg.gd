extends TextureRect

var color = Options.colorbg


func _process(delta):
	color = Options.colorbg
	modulate = Color(int(color[0] + color[1] + color[2]),int(color[4] + color[5] + color[6]),int(color[8]+color[9]+color[10]))
	if Options.scrollbg != "true":
		$AnimationPlayer.speed_scale = 0
	else:
		$AnimationPlayer.speed_scale = 0.01
