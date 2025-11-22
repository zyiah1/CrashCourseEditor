extends VBoxContainer

var data:PackedStringArray = []
var end = []
var childData = []
var childEnd = []
var targetnode = null

func _process(delta):
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
	
	if end != []: #if its a rail
		targetnode.set_point_data(data)
		targetnode.end = end
	else: #if its an object
		targetnode.data = data
	if childData != []:
		targetnode.childrail.data = childData
		targetnode.childrail.endplat = childEnd
	targetnode.reposition()

func _on_new_pressed():
	applydata()
	for node in get_children():
		node.queue_free()
	clear()
	owner.editednode.propertyclose() #undo history

func clear():
	owner.Groupnum = 0
	owner.propertypanel = false
	get_parent().get_parent().hide()
	data = []
	end = []
	childData = []
	childEnd = []
