extends TextureRect

var color: Color = Options.colorbg


func _process(delta):
	modulate = color
	color = Options.colorbg
	if Options.scrollbg != "true":
		
		return
	else:
		position -= Vector2(20,20)*delta
	
