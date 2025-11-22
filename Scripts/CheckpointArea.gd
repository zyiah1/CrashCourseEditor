extends Label

func _process(delta):
	owner.flip_h = false
	if owner.data[9].begins_with("            param0: 0"):
		owner.texture = preload("uid://beg5u4jtrga63") #checkpoint.png
	if owner.data[9].begins_with("            param0: 1"):
		owner.texture = preload("uid://d0to5kwvj5jt") #firstcheckpoint.png
		if owner.data[24].begins_with("            scale_x: -1"):
			owner.flip_h = true
		else:
			owner.flip_h = false
	if owner.data[9].begins_with("            param0: 2"):
		owner.texture = preload("uid://b2kj5qwe6msqy") #fincheckpoint.png
	text = str(int(owner.data[13].erase(0,20)))
	if owner.get_node("Button").is_hovered() and owner.get_parent().item == "tooledit":
		if Input.is_action_just_pressed("addpoint"):
			owner.data[13] = "            param0: "+str(int(owner.data[13].erase(0,20))+1)+".00000"
		if Input.is_action_just_pressed("bridge"):
			owner.data[13] = "            param0: "+str(int(owner.data[13].erase(0,20))-1)+".00000"
