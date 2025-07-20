extends Node2D

var target = 0
var rail

@export var previewtexture: Texture2D = load("res://rail.png")

@onready var crank = get_parent().get_node("crank")

func _ready():
	var inst = load("res://rail.tscn").instantiate()
	add_child(inst)
	rail = inst
	move_child(inst,0)
	inst.modulate = Color(.8,.8,.8,.6)
	rail.texture = previewtexture

func _process(delta):
	rotation_degrees = -crank.rotation_degrees
	rail.points = crank.rail.points
	position = crank.position
	rail.position = -position
