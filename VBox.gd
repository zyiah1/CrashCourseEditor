extends VBoxContainer

var data = []
var end = []
var childData = []
var childEnd = []
var targetnode = null

func _process(delta):
	if Input.is_action_just_pressed("accept"):
		for node in get_children():
			node.focus_mode = Control.FOCUS_NONE
			node.focus_mode = Control.FOCUS_ALL
	if Input.is_action_just_pressed("undo"):
		for node in get_children():
			node.queue_free()
		clear()



func _on_new_pressed():
	get_parent().get_parent()._on_Property_pressed()
	targetnode = get_parent().get_parent().get_parent().get_parent().editednode
	for node in get_children():
		if node.is_in_group("Data"):
			data.append(node.text)
		if node.is_in_group("End"):
			end.append(node.text)
		if node.is_in_group("ChildData"):
			childData.append(node.text)
		if node.is_in_group("ChildEnd"):
			childEnd.append(node.text)
		node.queue_free()
	targetnode.data = data
	if end != []:
		targetnode.end = end
	if childData != []:
		targetnode.childrail.data = childData
		targetnode.childrail.endplat = childEnd
	targetnode.reposition()
	clear()

func clear():
	get_parent().get_parent().get_parent().get_parent().Groupnum = 0
	get_parent().get_parent().get_parent().get_parent().propertypanel = false
	get_parent().get_parent().hide()
	data = []
	end = []
	childData = []
	childEnd = []
