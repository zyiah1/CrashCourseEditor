extends Node2D


var lines
@onready var start = get_parent().path[0]
@onready var end = get_parent().path[1]
var current = 1
@onready var path = get_parent().path.duplicate()
@onready var backpath = get_parent().path
var repeat = false
@onready var maxoffset = start - end
var offset = Vector2.ZERO



func _process(delta):
	if repeat == true:
		offset = Vector2.ZERO
		path = backpath.duplicate()
		repeat = false
	if lines != []:
		start = path[0]
		end = path[1]
		maxoffset = start - end
		offset = offset.move_toward(maxoffset,get_parent().speed)
		
		
		if offset == maxoffset:
			if current == 1:
				if path.size() != 2:
					path.remove_at(1)
					current = 0
				else:
					if get_parent().get_parent().get_parent().data == true:
						offset = Vector2.ZERO
						path = backpath.duplicate()
						repeat = false
		else:
			current = 1
		
		queue_redraw()
	

func _draw():
	lines = get_parent().lines
	for lineb in lines:
		draw_line(lineb[0] - offset,lineb[1] - offset,Color.REBECCA_PURPLE - Color(.1,.1,.1,0),4.5)

