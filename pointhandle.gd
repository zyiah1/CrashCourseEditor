extends Button

@onready var rail = owner.get_parent()

func _process(delta):
	visible = rail.fillmode
	if button_pressed:
		global_position = get_global_mouse_position()+Vector2(-7,-7)
	if rail.locked:
		queue_free()


func _on_mouse_entered():
	$AnimationPlayer.play("mousein")


func _on_mouse_exited():
	$AnimationPlayer.play("mouseout")
