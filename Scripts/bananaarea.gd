extends RichTextLabel

func _ready():
	var area = 0
	for value in owner.get_parent().checkpoints:
		if area in owner.get_parent().checkpoints:
			area += 1
	if area != 0:
		area -= 1
	await owner.ready
	owner.data[9] = "            param0: "+str(area)+".00000"

func _process(delta):
	text = str(int(owner.data[9].erase(0,20)))
	if owner.get_node("Button").is_hovered() and owner.get_parent().item == "edit":
		if Input.is_action_just_pressed("addpoint"):
			owner.data[9] = "            param0: "+str(int(owner.data[9].erase(0,20))+1)+".00000"
		if Input.is_action_just_pressed("bridge"):
			owner.data[9] = "            param0: "+str(int(owner.data[9].erase(0,20))-1)+".00000"
