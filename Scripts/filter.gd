extends TextEdit
signal rotationupdated(string)

@onready var prev = text

func _on_rotation_text_changed():
	emit_signal("rotationupdated",text)
	if text.is_valid_int() or text == "" or text == "-":
		if text.length() < 6:
			prev = text
		else:
			if text.length() < 7:
				if text.begins_with("-"):
					prev = text
					return
			text = prev
			set_caret_column(9)
	else:
		text = prev
		set_caret_column(9)
		
	

