extends Node2D

var lines = null
var target = 0


func _process(delta):
	rotation_degrees = move_toward(rotation_degrees,int(target),get_parent().speed)
	if Input.is_action_just_pressed("back"):
		rotation_degrees = 0
	if rotation_degrees == target:
		get_parent().speed = 1
		$cooldown.wait_time = 1
		if get_parent().get_parent().get_parent().data == true:
			if $Timer.is_stopped():
				$Timer.start(.3)
	queue_redraw()

func _draw():
	if lines != null:
		for lineb in lines:
			draw_line((lineb[0]-position),(lineb[1]-position),Color.LIGHT_SEA_GREEN - Color(.2,.2,.2,0),4.5)

func _on_Timer_timeout():
	rotation_degrees = 0


func _on_cooldown_timeout():
	if $cooldown.wait_time - .1 >= 0:
		$cooldown.wait_time -= .1
	get_parent().speed += 2


func _on_rotation_rotationupdated(string):
	target = int(string)
