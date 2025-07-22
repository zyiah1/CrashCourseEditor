extends Camera2D


var paused = false
var zoom_minimum = Vector2(.500001,.50001)
var zoom_maximum = Vector2(20.00001,20.00001)
var zoom_speed = Vector2(.120001,.120001)
var mouse_start_pos
var screen_start_pos
var dragging = false







func _physics_process(delta):
	if get_parent().propertypanel == false:
		if paused == false:
			if Input.is_action_pressed("ui_right"):
				position.x += 4 * zoom.x  
			if Input.is_action_pressed("ui_left"):
				position.x += -4 * zoom.x  
			if Input.is_action_pressed("ui_up"):
				position.y += -5 * zoom.x 
			if Input.is_action_pressed("ui_down"):
				if not Input.is_action_pressed("save"):
					position.y += 5 * zoom.x 
			if Input.is_action_just_pressed("zoom_out"):
				if zoom.x < 3:
					zoom += Vector2(.25,.25)
			if Input.is_action_just_pressed("zoom_in"):
				if zoom.x - .25 >= 0.5:
					zoom += Vector2(-.25,-.25)
			if Input.is_action_just_pressed("hide"):
				toggleUI()
	if Input.is_action_just_pressed("accept"):
		get_viewport().gui_release_focus()
	if Input.is_action_just_pressed("fullView"):
		toggleCam()

func toggleCam():
	if enabled:
		get_parent().get_node("ZoomOut").enabled = true
		enabled = false
		paused = true
	else:
		paused = false
		enabled = true
		get_parent().get_node("ZoomOut").enabled = false

func toggleUI():
	for node in get_tree().get_nodes_in_group("UI"):
		node.visible = not node.visible

func _input(event): #mouse inputs
	if event.is_action("drag"): #mouse dragging
		if event.is_pressed():
			mouse_start_pos = event.position
			screen_start_pos = position
			dragging = true
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		position = Vector2(1,1)/zoom * (mouse_start_pos - event.position) + screen_start_pos
	if event is InputEventMouseButton and get_parent().propertypanel == false: # zooming
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if zoom > zoom_minimum:
					zoom -= zoom_speed
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
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
