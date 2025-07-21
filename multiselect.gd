extends ColorRect

var rect: Rect2

func _process(delta):
	rect = Rect2(get_local_mouse_position(),position-get_global_mouse_position())
	queue_redraw()
	if Input.is_action_just_released("addpoint"):
		var pos1 = rect.end+position
		var pos2 = rect.position+position
		var positiveposx = pos1.x
		var negativeposx = pos2.x
		var positiveposy = pos1.y
		var negativeposy = pos2.y
		if pos1.x < pos2.x:
			positiveposx = pos2.x
			negativeposx = pos1.x
		if pos1.y < pos2.y:
			positiveposy = pos2.y
			negativeposy = pos1.y
		for node in get_parent().get_children():
			if node is Node2D:
				if node.visible == true and not node.is_in_group("ed") and node != self:
					if node.position.x > negativeposx and node.position.x < positiveposx:
						if node.position.y > negativeposy and node.position.y < positiveposy:
							if node.is_in_group("Object"):
								node.queue_free()
		queue_free()

func _draw():
	draw_rect(rect,Color.CYAN,true,)
