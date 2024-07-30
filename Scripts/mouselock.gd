extends CanvasLayer

var mouseX
var mouseY


func _process(delta):
	
	
	
	
	if Input.is_action_just_pressed("lock_x"):
		mouseX = get_viewport().get_mouse_position().x
	if Input.is_action_pressed("lock_x"):
		get_viewport().warp_mouse(Vector2(mouseX,get_viewport().get_mouse_position().y))
	if Input.is_action_just_pressed("lock_y"):
		mouseY = get_viewport().get_mouse_position().y
	if Input.is_action_pressed("lock_y"):
		get_viewport().warp_mouse(Vector2(get_viewport().get_mouse_position().x,mouseY))
