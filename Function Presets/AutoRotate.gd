extends Control

onready var Vbox = get_parent().get_parent().get_node("ScrollContainer/VBox")
var pointsx = []
var pointsy = []
var numberofpoints = 0
var speed
var rotation
var id

func _ready():
	$HugePanel.hide()
	for child in Vbox.get_children():
		if child.text.begins_with("                  pnt0_x: "):
			pointsx.append(child)
		if child.text.begins_with("                  pnt0_y: "):
			pointsy.append(child)
			$OptionButton.add_item(str(numberofpoints))
			numberofpoints += 1
		if child.text.begins_with("              param0: "):
			id = child
		if child.text.begins_with("              param1: "):
			rotation = child
		if child.text.begins_with("              param2: "):
			speed = child
	$X.text = pointsx[0].text.lstrip("                  pnt0_x: ")
	$Y.text = pointsy[0].text.lstrip("                  pnt0_y: ")
	if $X.text == "":
		$X.text = "0"
	if $Y.text == "":
		$Y.text = "0"
	
	var text = speed.text
	
	text.erase(0,22)
	$Speed.text = text
	text = rotation.text
	text.erase(0,22)
	$Rotation.text = text
	if id.text == "              param0: 3200.00000":
		$returns.pressed = true


func _process(delta):
	if Input.is_action_just_pressed("accept"):
		$Y.grab_focus()
		$Y.hide()
		$Y.show()



func _on_OptionButton_item_selected(index):
	$X.text = pointsx[int($OptionButton.text)].text.lstrip("                  pnt0_x: ")
	$Y.text = pointsy[int($OptionButton.text)].text.lstrip("                  pnt0_y: ")

func _on_X_text_changed(new_text):
	pointsx[int($OptionButton.text)].text = "                  pnt0_x: " + str(new_text)


func _on_Y_text_changed(new_text):
	pointsy[int($OptionButton.text)].text = "                  pnt0_y: " + str(new_text)


func _on_Speed_text_changed(new_text):
	speed.text = "              param2: " + $Speed.text


func _on_Rotation_text_changed(new_text):
	rotation.text = "              param1: " + $Rotation.text


func _on_returns_pressed():
	if $returns.pressed:
		id.text = "              param0: 3200.00000"
	else:
		id.text = "              param0: 3300.00000"
