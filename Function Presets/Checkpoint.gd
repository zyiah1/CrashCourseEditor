extends Control

@onready var Vbox = get_parent().get_parent().get_node("ScrollContainer/VBox")
var posx = null
var posy = null

var type1 = null
var type2 = null

var points = null
var area = null

var scalex = null


func _ready():
	$HugePanel.hide()
	for child in Vbox.get_children():
		if child.text.begins_with("            pos_x: "):
			posx = child
		if child.text.begins_with("            pos_y: "):
			posy = child
		if child.text.begins_with("            scale_x: "):
			scalex = child
		if child.text.begins_with("            param0: "):
			type1 = child
		if child.text.begins_with("            param1: "):
			type2 = child
		if child.text.begins_with("            param2: "):
			area = child
		if child.text.begins_with("            param4: "):
			points = child
	$X.text = posx.text.lstrip("            pos_x: ")
	$Y.text = posy.text.lstrip("            pos_y: ")
	if $X.text == "":
		$X.text = "0"
	if $Y.text == "":
		$Y.text = "0"
	
	var newtext = points.text
	newtext.erase(0,20)
	
	$point.text = newtext
	
	var newtext2 = area.text
	newtext2.erase(0,20)
	
	$area.text = newtext2
	
	$type.add_item("normal")
	$type.add_item("first")
	$type.add_item("ends level")
	
	$face.add_item("right")
	$face.add_item("left")
	
	if type1.text.begins_with("            param0: 1"):
		#first
		$type.select(1)
	if type1.text.begins_with("            param0: 2"):
		#final
		$type.select(2)
	
	if scalex.text.begins_with("            scale_x: -1"):
		$face.select(1)


func _process(delta):
	if Input.is_action_just_pressed("accept"):
		$X.hide()
		$Y.hide()
		$X.show()
		$Y.show()



func _on_X_text_changed(new_text):
	posx.text = "            pos_x: " + str(new_text)


func _on_Y_text_changed(new_text):
	posy.text = "            pos_y: " + str(new_text)


func _on_point_text_changed(new_text):
	points.text = "            param4: " + new_text


func _on_area_text_changed(new_text):
	area.text = "            param2: "+new_text


func _on_type_item_selected(index):
	var newtext = ""
	match index:
		
		0:
			newtext = " 0.00000"
		1:
			newtext = " 1.00000"
		2:
			newtext = " 2.00000"
		
	type1.text = "            param0:" + newtext
	
	type2.text = "            param1:" + newtext


func _on_face_item_selected(index):
	if index == 0:
		scalex.text = "            scale_x: 1.00000"
	else:
		scalex.text = "            scale_x: -1.00000"
