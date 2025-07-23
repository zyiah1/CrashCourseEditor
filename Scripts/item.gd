extends Button

signal selected

var icon1: Texture2D
@export var icon2: Texture2D
@export var icon3: Texture2D

func _ready():
	icon1 = icon

func _process(delta):
	if icon2 != null:
		match owner.mode:
			1:
				icon = icon1
			2:
				icon = icon2
			3:
				icon = icon3

func _pressed():
	if owner.propertypanel == false:
		for buttons in get_tree().get_nodes_in_group("button"):
			buttons.disabled = false
		disabled = true
		
		emit_signal("selected",str(name))
