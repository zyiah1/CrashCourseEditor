extends TextureRect

var color = Options.colorbg


func _process(delta):
	color = Options.colorbg
	modulate = color
	if Options.scrollbg != "true":
		
		return
	else:
		position -= Vector2(20,20)*delta
	
