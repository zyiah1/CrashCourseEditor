extends Button

func _ready():
	if not FileAccess.open("Dkb.settings",FileAccess.READ_WRITE):
		print("WELCOME")
		$Node2D/FileWindoe.popup(Rect2(-790,-429,1022,580))

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://settings.tscn")

func _on_FileWindoe_dir_selected(dir):
	if not str(dir).ends_with("/"):
		Options.filepath = dir + "/"
	else:
		Options.filepath = dir
	Options.save()
