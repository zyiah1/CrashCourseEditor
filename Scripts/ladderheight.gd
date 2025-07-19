extends Control

var loading = false

func _ready():
	if loading == false:
		grab_focus()
	else:
		hide()

func _process(delta):
	if Input.is_action_just_pressed("accept"):
		hide()
	if owner.get_parent().item == "edit" and owner.get_node("Button").button_pressed:
		
		var dirflip = false
		var ladderframe = int(owner.data[9].lstrip("            param0: "))
		if owner.data[3].begins_with("            dir_z: 180"):
			dirflip = true
		
		if dirflip == true:
			owner.rotation_degrees = 0
			owner.flip_v = true
			match ladderframe:
				1:
					ladderframe = 0
				2:
					ladderframe = -1
				3:
					ladderframe = -2
				4:
					ladderframe = -3
				5:
					ladderframe = -4
				6:
					ladderframe = -5
		show()
		grab_focus()
		$slider.value = ladderframe
	match int(owner.data[9].lstrip("            param0: ")):
		1:
			owner.texture = preload("res://ladder1.png")
		2:
			owner.texture = preload("res://ladder2.png")
		4:
			owner.texture = preload("res://ladder4.png")
		5:
			owner.texture = preload("res://ladder5.png")
		6:
			owner.texture = preload("res://ladder6.png")



func _on_slider_value_changed(value):
	var laddernumber = value
	
	if value<1:
		owner.flip_v = true
		owner.data[3] = "            dir_z: 180.00000"
	else:
		owner.flip_v = false
		owner.data[3] = "            dir_z: 0.00000"
	match int(value):
		1:
			owner.texture = preload("res://ladder1.png")
		2:
			owner.texture = preload("res://ladder2.png")
		3:
			owner.texture = preload("res://ladder.png")
		4:
			owner.texture = preload("res://ladder4.png")
		5:
			owner.texture = preload("res://ladder5.png")
		6:
			owner.texture = preload("res://ladder6.png")
		0:
			owner.texture = preload("res://ladder1.png")
			laddernumber = 1
		-1:
			owner.texture = preload("res://ladder2.png")
			laddernumber = 2
		-2:
			owner.texture = preload("res://ladder.png")
			laddernumber = 3
		-3:
			owner.texture = preload("res://ladder4.png")
			laddernumber = 4
		-4:
			owner.texture = preload("res://ladder5.png")
			laddernumber = 5
		-5:
			owner.texture = preload("res://ladder6.png")
			laddernumber = 6
	owner.data[9] = "            param0: "+str(laddernumber)+".00000"


func _on_focus_entered():
	show()

func _on_focus_exited():
	hide()
	if owner.flip_v == true:
		owner.rotation_degrees = 180
	else:
		owner.rotation_degrees = 0
	owner.flip_v = false
