extends Button

func _process(delta):
	visible = owner.fillmode
	if button_pressed:
		global_position = get_global_mouse_position()+Vector2(-7,-7)
	if owner.locked:
		queue_free()
