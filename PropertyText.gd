extends LineEdit

signal text_set

@onready var oldtext = text

func _process(delta):
	if text != oldtext:
		oldtext = text
		emit_signal("text_set",text)
