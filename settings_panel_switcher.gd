extends TabBar



func _on_tab_changed(tab):
	print(tab)
	for node in get_children():
		node.hide()
	get_child(tab).show()
