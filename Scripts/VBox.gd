extends VBoxContainer

var data:PackedStringArray = []
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


func applydata():
	data = []
	end = []
	childData = []
	childEnd = []
	targetnode = owner.editednode
	for node in get_children():
		if node.is_in_group("Data"):
			data.append(node.text)
		if node.is_in_group("End"):
			end.append(node.text)
		if node.is_in_group("ChildData"):
			childData.append(node.text)
		if node.is_in_group("ChildEnd"):
			childEnd.append(node.text)
	targetnode.data = data
	if end != []:
		targetnode.end = end
	if childData != []:
		targetnode.childrail.data = childData
		targetnode.childrail.endplat = childEnd
	targetnode.reposition()

func _on_new_pressed():
	# change back to normal tab
	applydata()
	for node in get_children():
		node.queue_free()
	clear()
	owner.editednode.propertyclose() #undo history

func clear():
	get_parent().get_parent()._on_Functions_pressed()
	owner.Groupnum = 0
	owner.propertypanel = false
	get_parent().get_parent().hide()
	data = []
	end = []
	childData = []
	childEnd = []
