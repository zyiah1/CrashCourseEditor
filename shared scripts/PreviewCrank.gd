extends Node2D

var target = 0
var rail

@export var previewtexture: Texture2D = preload("uid://bvrfm1i201crx") #rail.png

func _ready():
	var inst = load("res://rail.tscn").instantiate()
	add_child(inst)
	rail = inst
	move_child(inst,$Timer.get_index()+1)
	inst.modulate = Color(.8,.8,.8,.6)
	rail.texture = previewtexture

func _process(delta):
	rotation_degrees = move_toward(rotation_degrees,float(target),get_parent().speed*delta*60)
	rail.position = -position
	if Input.is_action_just_pressed("back"):
		rotation_degrees = 0
	if rotation_degrees == target:
		if get_parent().get_parent().get_parent().movingLoop == true:
			if $Timer.is_stopped():
				$Timer.start(.3)
	


func _on_Timer_timeout():
	rotation_degrees = 0

func _on_rotation_rotationupdated(string):
	target = float(string)
