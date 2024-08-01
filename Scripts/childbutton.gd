extends Button

#func _process(delta):
	#if Input.is_action_just_pressed(name):
		#print(name)

func _pressed():
	for buttons in get_tree().get_nodes_in_group("button"):
		buttons.disabled = false
	disabled = true
	
	
	get_parent().get_parent().get_parent().get_parent().item = str(name)
	


