extends Button

var color
var custom = false

func _on_custom_pressed():
	$ColorPicker.visible = not $ColorPicker.visible
	custom = true




func _process(delta):
	if custom == true:
		Options.colorbg = $ColorPicker.color

