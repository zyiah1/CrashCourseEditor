extends Node2D

var target = 0
var rail

@export var previewtexture: Texture2D = load("res://rail.png")

func _ready():
	var inst = load("res://rail.tscn").instantiate()
	add_child(inst)
	rail = inst
	move_child(inst,$Timer.get_index()+1)
	inst.modulate = Color(.8,.8,.8,.5)
	rail.texture = previewtexture

func _process(delta):
	rotation_degrees = move_toward(rotation_degrees,int(target),get_parent().speed)
	rail.position = -position
	if Input.is_action_just_pressed("back"):
		rotation_degrees = 0
	if rotation_degrees == target:
		get_parent().speed = 1
		$cooldown.wait_time = 1
		if get_parent().get_parent().get_parent().data == true:
			if $Timer.is_stopped():
				$Timer.start(.3)
	


func _on_Timer_timeout():
	rotation_degrees = 0


func _on_cooldown_timeout():
	if $cooldown.wait_time - .1 >= 0:
		$cooldown.wait_time -= .1
	get_parent().speed += 2


func _on_rotation_rotationupdated(string):
	target = int(string)
