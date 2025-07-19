extends Control

@onready var Vbox = get_parent().get_parent().get_node("ScrollContainer/VBox")
#references to imputs
var pointsx = []
var pointsy = []
var ID = null
var numberofpoints = 0
var speed
var rotation_text
var rotation_point

func _ready():
	$HugePanel.hide()
	for child in Vbox.get_children():
		if child.text.begins_with("                  pnt0_x: "):
			pointsx.append(child)
		if child.text.begins_with("                  pnt0_y: "):
			pointsy.append(child)
			$OptionButton.add_item(str(numberofpoints))
			$RotatingPoint.add_item(str(numberofpoints))
			numberofpoints += 1
		if child.text.begins_with("              param1: "):
			rotation_text = child
		if child.text.begins_with("              param2: "):
			speed = child
		if child.text.begins_with("              param3: "):
			rotation_point = child
		if child.text.begins_with("              param0: ") and child.is_in_group("End"):
			ID = child
	$X.text = pointsx[0].text.lstrip("                  pnt0_x: ")
	$Y.text = pointsy[0].text.lstrip("                  pnt0_y: ")
	if $X.text == "":
		$X.text = "0"
	if $Y.text == "":
		$Y.text = "0"
	
	var text = speed.text
	
	text = text.erase(0,22)
	$Speed.text = text
	text = rotation_text.text
	text = text.erase(0,22)
	$Rotation.text = text
	text = rotation_point.text
	text = text.erase(0,22)
	$RotatingPoint.select(int(text))
	$Trigger.selected = $Trigger.get_item_index(int(ID.text.erase(0,22)))

func _process(delta):
	if Input.is_action_just_pressed("accept"):
		$Y.grab_focus()
		$Y.hide()
		$Y.show()



func _on_OptionButton_item_selected(_index):
	$X.text = pointsx[int($OptionButton.text)].text.lstrip("                  pnt0_x: ")
	$Y.text = pointsy[int($OptionButton.text)].text.lstrip("                  pnt0_y: ")

func _on_X_text_changed(new_text):
	pointsx[int($OptionButton.text)].text = "                  pnt0_x: " + str(new_text)


func _on_Y_text_changed(new_text):
	pointsy[int($OptionButton.text)].text = "                  pnt0_y: " + str(new_text)


func _on_Speed_text_changed(new_text):
	speed.text = "              param2: " + new_text


func _on_Rotation_text_changed(new_text):
	rotation_text.text = "              param1: " + new_text


func _on_trigger_item_selected(index):
	ID.text = "              param0: "+str($Trigger.get_item_id(index))+".00000"


func _on_rotating_point_item_selected(index):
	rotation_point.text = "              param3: " + str(index)
