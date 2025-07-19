extends Label

func _process(delta):
	owner.flip_h = false
	if owner.data[9].begins_with("            param0: 0"):
		owner.texture = preload("res://checkpoint.png")
	if owner.data[9].begins_with("            param0: 1"):
		owner.texture = preload("res://firstcheckpoint.png")
		if owner.data[24].begins_with("            scale_x: -1"):
			owner.flip_h = true
		else:
			owner.flip_h = false
	if owner.data[9].begins_with("            param0: 2"):
		owner.texture = preload("res://fincheckpoint.png")
	text = str(int(owner.data[13].erase(0,20)))
