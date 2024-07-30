extends TextEdit

var prev = "2"
signal change

func _on_rotation_text_changed():
	if text.is_valid_float() or text == "":
		if text.count(".",0,10) == 1:
			if text.length() < 6:
				prev = text
				text = prev
				cursor_set_column(9)
				emit_signal("change")
			else:
				text = prev
				cursor_set_column(9)
		else:
			if text.length() < 4:
				prev = text
				text = prev
				cursor_set_column(9)
				emit_signal("change")
			else:
				text = prev
				cursor_set_column(9)
	else:
		text = prev
		cursor_set_column(9)
		
	
