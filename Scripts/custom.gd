extends Button

var color
var custom = false

func _on_custom_pressed():
	$ColorPicker.visible = not $ColorPicker.visible
	custom = true




func _process(delta):
	if custom == true:
		color = str(snapped($ColorPicker.color.r,0.1))+ "," +str(snapped($ColorPicker.color.g,.1)) +"," + str(snapped($ColorPicker.color.b,.1))
		
		
		"1.0,1.0,1."
		
		if color[1] != ".":
			color = color.insert(1,".0")
		if color[5] != ".":
			color = color.insert(5,".0")
		
		if color.length() < 11:
			color += ".0"
		
		Options.colorbg = color

