extends Node2D

@export var previewtexture:Texture2D = preload("uid://bvrfm1i201crx") #rail.png

var currentpoint = 0
var repeat: bool = false
var rail


func _ready():
	var inst = load("res://rail.tscn").instantiate()
	add_child(inst)
	rail = inst
	rail.modulate = Color(.8,.8,.8,.6)
	rail.texture = previewtexture

func _process(delta):
	if rail.points.size() > 2:
		var start = owner.get_parent().points[0].position
		var end = owner.get_parent().points[currentpoint+1].position
		var maxoffset = end-start
		rail.position = rail.position.move_toward(maxoffset,get_parent().speed*delta*60) #60fps like the original's
		
		
		if rail.position == maxoffset:
			if owner.get_parent().points.size() > currentpoint+2:
				currentpoint += 1
			elif owner.Editor.movingLoop == true:
				rail.position = Vector2.ZERO
				currentpoint = 0
				repeat = false
		if repeat == true:
			rail.position = Vector2.ZERO
			currentpoint = 0
			repeat = false
