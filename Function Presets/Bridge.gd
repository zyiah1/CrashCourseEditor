extends Control

@onready var Vbox = get_parent().get_parent().get_node("ScrollContainer/VBox")
var railtype = null
var pointsx = []
var pointsy = []
var numberofpoints = 0

func _ready():
	$HugePanel.hide()
	for child in Vbox.get_children():
		if child.text.begins_with("              param0: "):
			railtype = child
		if child.text.begins_with("                  pnt0_x: "):
			pointsx.append(child)
		if child.text.begins_with("                  pnt0_y: "):
			pointsy.append(child)
			$OptionButton.add_item(str(numberofpoints))
			numberofpoints += 1
	$X.text = pointsx[0].text.lstrip("                  pnt0_x: ")
	$Y.text = pointsy[0].text.lstrip("                  pnt0_y: ")
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

func _on_Red_pressed():
	railtype.text = "              param0: 1000.00000"


func _on_Blue_pressed():
	railtype.text = "              param0: 1200.00000"


func _on_Invisible_pressed():
	railtype.text = "              param0: 0.00000"


func _on_OptionButton_item_selected(_index):
	$X.text = pointsx[int($OptionButton.text)].text.lstrip("                  pnt0_x: ")
	$Y.text = pointsy[int($OptionButton.text)].text.lstrip("                  pnt0_y: ")

func _on_X_text_changed(new_text):
	pointsx[int($OptionButton.text)].text = "                  pnt0_x: " + str(new_text)


func _on_Y_text_changed(new_text):
	pointsy[int($OptionButton.text)].text = "                  pnt0_y: " + str(new_text)
