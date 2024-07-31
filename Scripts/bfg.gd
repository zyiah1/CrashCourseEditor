extends TextureRect

var color = Options.colorbg


func _process(delta):
	color = Options.colorbg
	modulate = color
	if Options.scrollbg != "true":
		$AnimationPlayer.speed_scale = 0
	else:
		$AnimationPlayer.speed_scale = 0.01
