extends TextureRect

var color: Color = Options.colorbg
var scaleamount = Vector2(4.5,4.5)

func _ready():
	modulate = color
	scale = scaleamount

func _process(delta):
	modulate = color
	color = Options.colorbg
	if Options.scrollbg == "true":
		pivot_offset += Vector2(5,5)*delta
		scale = scaleamount
		#pivot_offset = -position
	
