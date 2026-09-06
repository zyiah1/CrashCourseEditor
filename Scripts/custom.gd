extends Button

var color
var custom = false

func _on_custom_pressed():
	visible = not visible
	custom = true




func _process(delta):
	if custom == true:
		Options.colorbg = $ColorPicker.color


func _on_ok_pressed():
	visible = not visible
