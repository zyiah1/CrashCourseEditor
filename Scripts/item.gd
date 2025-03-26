extends Button

signal selected
#func _process(delta):
	#if Input.is_action_just_pressed(name):
		#print(name)

func _pressed():
	for buttons in get_tree().get_nodes_in_group("button"):
		buttons.disabled = false
	disabled = true
	
	emit_signal("selected",str(name))
