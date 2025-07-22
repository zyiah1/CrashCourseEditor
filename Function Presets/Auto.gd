extends Control

@onready var Vbox = get_parent().get_parent().get_node("ScrollContainer/VBox")
var trackvisible = null
var speed = null
var reset = null
var ID = null
var pointsx = []
var pointsy = []
var childpointsx = []
var childpointsy = []

var cameramoveY = null

var numberofpoints = 0
var childnumberofpoints = 0

func _ready():
	$HugePanel.queue_free()
	for child in Vbox.get_children():
		if child.is_in_group("ChildData"):
			if child.text.begins_with("                  pnt0_x: "):
				childpointsx.append(child)
			if child.text.begins_with("                  pnt0_y: "):
				childpointsy.append(child)
				$ChildOptionButton.add_item(str(childnumberofpoints))
				childnumberofpoints += 1
		else:
			if child.text.begins_with("                  pnt0_x: "):
				pointsx.append(child)
			if child.text.begins_with("                  pnt0_y: "):
				pointsy.append(child)
				$OptionButton.add_item(str(numberofpoints))
				numberofpoints += 1
			if child.is_in_group("ChildEnd"):
				if child.text.begins_with("              param0: "):
					ID = child
				if child.text.begins_with("              param2: "):
					speed = child
				if child.text.begins_with("              param3: "):
					reset = child
				if child.text.begins_with("              param6: "):
					cameramoveY = child
			if child.is_in_group("End"):
				if child.text.begins_with("              param1: "):
					trackvisible = child
	$X.text = pointsx[0].text.lstrip("                  pnt0_x: ")
	$Y.text = pointsy[0].text.lstrip("                  pnt0_y: ")
	if $X.text == "":
		$X.text = "0"
	if $Y.text == "":
		$Y.text = "0"
	$ChildX.text = childpointsx[0].text.lstrip("                  pnt0_x: ")
	$ChildY.text = childpointsy[0].text.lstrip("                  pnt0_y: ")
	if $ChildX.text == "":
		$ChildX.text = "0"
	if $ChildY.text == "":
		$ChildY.text = "0"
	
	var text = speed.text.erase(0,22)
	$Speed.text = text
	if trackvisible.text.begins_with("              param1: 0"):
		$visible.button_pressed = false
	
	if reset.text.begins_with("              param3: -1"):
		$reset.button_pressed = false
	
	if ID.text.begins_with("              param0: 2300") or ID.text.begins_with("              param0: 2000") :
		$returns.button_pressed = false
	
	if ID.text.begins_with("              param0: 4300"):
		$camera/check.button_pressed = true
		$AnimationPlayer.play("Move Camera3D On")
		$camera/CamY.text = cameramoveY.text.lstrip("              param6:")
	$Type.selected = $Type.get_item_index(int(ID.text.erase(0,22)))


#-1               param3:  == no reset on spawn

func _process(delta):
	for node in get_tree().get_nodes_in_group("camprev"):
		if $camera/CamY.has_focus():
			node.position = -Vector2(0,float($camera/CamY.text)*1.7)
			node.show()
		else:
			node.hide()


func _on_OptionButton_item_selected(_index):
	$X.text = pointsx[int($OptionButton.text)].text.lstrip("                  pnt0_x: ")
	$Y.text = pointsy[int($OptionButton.text)].text.lstrip("                  pnt0_y: ")

func _on_X_text_changed(new_text):
	pointsx[int($OptionButton.text)].text = "                  pnt0_x: " + str(new_text)


func _on_Y_text_changed(new_text):
	pointsy[int($OptionButton.text)].text = "                  pnt0_y: " + str(new_text)


func _on_ChildOptionButton_item_selected(_index):
	$ChildX.text = childpointsx[int($ChildOptionButton.text)].text.lstrip("                  pnt0_x: ")
	$ChildY.text = childpointsy[int($ChildOptionButton.text)].text.lstrip("                  pnt0_y: ")


func _on_ChildX_text_changed(new_text):
	childpointsx[int($ChildOptionButton.text)].text = "                  pnt0_x: " + str(new_text)


func _on_ChildY_text_changed(new_text):
	childpointsy[int($ChildOptionButton.text)].text = "                  pnt0_y: " + str(new_text)


func _on_Speed_text_changed(new_text):
	speed.text = "              param2: " + new_text


func _on_CheckButton_pressed():
	if $visible.button_pressed:
		trackvisible.text = "              param1: -1.00000"
	else:
		trackvisible.text = "              param1: 0.00000"


func _on_reset_pressed():
	if $reset.button_pressed:
		reset.text = "              param3: 1"
	else:
		reset.text = "              param3: -1"


func _on_returns_pressed():
	if $returns.button_pressed:
		ID.text = "              param0: 2200.00000"
	else:
		ID.text = "              param0: 2300.00000"



func _on_camera_pressed():
	if $camera/check.button_pressed:
		ID.text = "              param0: 4300.00000"
		$AnimationPlayer.play("Move Camera3D On")
	else:
		ID.text = "              param0: 2300.00000"
		$returns.button_pressed = false
		$AnimationPlayer.play("Move Camera3D Off")
		cameramoveY.text = "              param6: -1.00000"
		$camera/CamY.text = ""


func _on_CamY_text_changed(new_text):
	cameramoveY.text = "              param6: " + new_text

func _on_type_item_selected(index):
	var id = $Type.get_item_id(index)
	ID.text = "              param0: "+str(id)+".00000"
