extends Button

signal selected

var names: PackedStringArray = []
@export var additional_names: PackedStringArray
var Editor


func startup():
	Editor = Options.Editor
	names = [name]
	names += additional_names
	if ResourceLoader.exists("res://UI/railart/"+name+".png"):
		icon = load("res://UI/railart/"+name+".png")
	else:
		queue_free()

func _process(delta):
	if Input.is_action_just_pressed("ChangeType") and names.size()>1:
		if names.find(name)+1 == names.size():
			name = names[0]
		else:
			name = names[names.find(name)+1]
		icon = load("res://UI/railart/"+name+".png")
		if disabled:
			emit_signal("selected",str(name))

func _pressed():
	if Editor.propertypanel == false:
		for buttons in get_tree().get_nodes_in_group("button"):
			buttons.disabled = false
		disabled = true
		
		emit_signal("selected",str(name))
