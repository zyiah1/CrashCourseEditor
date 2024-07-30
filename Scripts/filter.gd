extends TextEdit
signal rotationupdated(string)

var prev = ""

func _on_rotation_text_changed():
	emit_signal("rotationupdated",text)
	if text.is_valid_integer() or text == "" or text == "-":
		if text.length() < 6:
			prev = text
		else:
			if text.length() < 7:
				if text.begins_with("-"):
					prev = text
					return
			text = prev
			cursor_set_column(9)
	else:
		text = prev
		cursor_set_column(9)
		
	

