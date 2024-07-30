extends Control

onready var Vbox = get_parent().get_parent().get_node("ScrollContainer/VBox")
var posx = null
var posy = null
var rotation = null
var scalex = null
var scaley = null


func _ready():
	$HugePanel.hide()
	for child in Vbox.get_children():
		if child.text.begins_with("            pos_x: "):
			posx = child
		if child.text.begins_with("            pos_y: "):
			posy = child
		if child.text.begins_with("            dir_z: "):
			rotation = child
		if child.text.begins_with("            scale_x: "):
			scalex = child
		if child.text.begins_with("            scale_y: "):
			scaley = child
	$X.text = posx.text.lstrip("            pos_x: ")
	$Y.text = posy.text.lstrip("            pos_y: ")
	$ScaleX.text = scalex.text.lstrip("            scale_x: ")
	$ScaleY.text = scaley.text.lstrip("            scale_y: ")
	$Rotation.text = rotation.text.lstrip("            dir_z: ")
	if $X.text == "":
		$X.text = "0"
	if $Y.text == "":
		$Y.text = "0"
	

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


func _on_ScaleX_text_changed(new_text):
	scalex.text = "            scale_x: " + new_text


func _on_ScaleY_text_changed(new_text):
	scaley.text = "            scale_y: " + new_text


func _on_Rotation_text_changed(new_text):
	rotation.text = "            dir_z: " + new_text
