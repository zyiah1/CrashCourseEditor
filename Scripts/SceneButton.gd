extends Button

@export var scene:PackedScene = preload("res://Creator.tscn")
@export var path:String = "res://settings_screen.tscn"
@export var use_packed:bool = true


func _pressed():
	if use_packed:
		get_tree().change_scene_to_packed(scene)
	else:
		get_tree().change_scene_to_file(path)
