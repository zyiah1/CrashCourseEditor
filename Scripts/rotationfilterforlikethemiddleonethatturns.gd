extends TextEdit

var prev = ""
signal rotationupdated(string)

func _on_rotation_text_changed():
	emit_signal("rotationupdated",text)
	if text.is_valid_integer() or text == "":
		if text.length() < 6:
			prev = text
		else:
			text = prev
			cursor_set_column(9)
	else:
		text = prev
		cursor_set_column(9)
		
	
