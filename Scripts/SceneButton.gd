extends Button

@export var scene:PackedScene = preload("res://Creator.tscn")

func _pressed():
	get_tree().change_scene_to_packed(scene)
