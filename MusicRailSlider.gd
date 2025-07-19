extends Control

var firstpress = true

func _ready():
	hide()
	owner.connect("edit", Callable(self,"edit"))
	if owner.loading == true:
		firstpress = false

func _process(delta):
	if Input.is_action_just_pressed("bridge") and firstpress:
		firstpress = false
		position = owner.get_node("start").position
		grab_focus()
		$AnimationPlayer.play("appear")

func edit():
	if owner.end[9][22] == "1":
		$slider.value = int("1"+owner.end[9].lstrip("              param1:"))
	else:
		$slider.value = int(owner.end[9].lstrip("              param1:"))
	grab_focus()
	$AnimationPlayer.play("appear")

func _on_focus_entered():
	show()


func _on_focus_exited():
	hide()


func _on_slider_value_changed(value):
	$number.text = str(int(value))
	if $number.text == "-1":
		$number.text = "Disabled"
	owner.end[9] = "              param1: "+str(int(value))+".00000"
