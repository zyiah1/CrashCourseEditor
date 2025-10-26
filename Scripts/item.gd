extends Button

signal selected

@onready var names: PackedStringArray = [name]
@export var additional_names: PackedStringArray

func _ready():
	names += additional_names
	icon = load("res://railart/"+name+".png")

func _process(delta):
	if Input.is_action_just_pressed("ChangeType") and names.size()>1:
		if names.find(name)+1 == names.size():
			name = names[0]
		else:
			name = names[names.find(name)+1]
		icon = load("res://railart/"+name+".png")
		if disabled:
			emit_signal("selected",str(name))

func _pressed():
	if owner.propertypanel == false:
		for buttons in get_tree().get_nodes_in_group("button"):
			buttons.disabled = false
		disabled = true
		
		emit_signal("selected",str(name))
