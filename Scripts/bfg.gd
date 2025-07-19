extends TextureRect

var color: Color = Options.colorbg

func _ready():
	modulate = color

func _process(delta):
	modulate = color
	color = Options.colorbg
	if Options.scrollbg == "true":
		position -= Vector2(20,20)*delta
	
