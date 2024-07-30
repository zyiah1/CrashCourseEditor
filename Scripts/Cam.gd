extends Camera2D


var paused = false
var zoom_minimum = Vector2(.1000001,.100001)
var zoom_maximum = Vector2(3.00001,3.00001)
var zoom_speed = Vector2(.100001,.100001)




func _physics_process(delta):
	if get_parent().propertypanel == false:
		if paused == false:
			if Input.is_action_pressed("ui_right"):
				position.x += 5 * zoom.x  * 2
			if Input.is_action_pressed("ui_left"):
				position.x += -5 * zoom.x  * 2
			if Input.is_action_pressed("ui_up"):
				position.y += -7 * zoom.x  * 2
			if Input.is_action_pressed("ui_down"):
				if not Input.is_action_pressed("save"):
					position.y += 7 * zoom.x * 2
			if Input.is_action_just_pressed("zoom_in"):
				if zoom.x < 3:
					zoom += Vector2(.25,.25)
			if Input.is_action_just_pressed("zoom_out"):
				if zoom.x - .25 != 0:
					zoom += Vector2(-.25,-.25)
			if Input.is_action_just_pressed("hide"):
				get_parent().get_node("CanvasLayer3/CanvasLayer2").visible = not get_parent().get_node("CanvasLayer3/CanvasLayer2").visible
				get_parent().get_node("CanvasLayer3/CanvasLayer").visible = not get_parent().get_node("CanvasLayer3/CanvasLayer").visible
				get_parent().get_node("nonmoving").visible = not get_parent().get_node("nonmoving").visible
	if Input.is_action_just_pressed("accept"):
		get_parent().get_node("nonmoving/name").focus_mode = Control.FOCUS_NONE
		get_parent().get_node("nonmoving/name").focus_mode = Control.FOCUS_ALL
	if Input.is_action_just_pressed("fullView"):
		if enabled == false:
			enabled = true
		else:
			get_parent().get_node("ZoomOut").enabled = true

func _input(event):
	if get_parent().propertypanel == false:
		if event is InputEventMouseButton:
			if event.is_pressed():
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					if zoom > zoom_minimum:
						zoom -= zoom_speed
				if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					if zoom < zoom_maximum:
						zoom += zoom_speed


func _on_name_focus_exited():
	if get_parent().get_node("nonmoving/name").text == "":
		get_parent().get_node("nonmoving/name").text = "untitled"
	paused = false


func _on_name_focus_entered():
	if get_parent().get_node("nonmoving/name").text == "untitled":
		get_parent().get_node("nonmoving/name").text = ""
	paused = true
