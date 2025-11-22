extends Node2D

@export var previewtexture:Texture2D = preload("uid://bvrfm1i201crx") #rail.png

@onready var start = get_parent().path[0]
@onready var end = get_parent().path[1]
@onready var path = get_parent().path.duplicate()
@onready var backpath = get_parent().path
@onready var maxoffset = start - end

var offset = Vector2.ZERO
var current: int = 1
var repeat: bool = false

var rail

func _ready():
	var inst = load("res://rail.tscn").instantiate()
	add_child(inst)
	rail = inst
	rail.modulate = Color(.8,.8,.8,.6)
	rail.texture = previewtexture

func _process(delta):
	if repeat == true:
		offset = Vector2.ZERO
		path = backpath.duplicate()
		repeat = false
	if rail.points.size() > 1:
		start = path[0]
		end = path[1]
		maxoffset = start - end
		offset = offset.move_toward(maxoffset,get_parent().speed*delta*60) #60fps like the original's
		
		
		if offset == maxoffset:
			if current == 1:
				if path.size() > 2:
					path.remove_at(1)
					current = 0
				elif get_parent().get_parent().get_parent().movingLoop == true:
					offset = Vector2.ZERO
					path = backpath.duplicate()
					repeat = false
		current = 1
		
		rail.position = -offset
