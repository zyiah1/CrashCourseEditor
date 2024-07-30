extends Button

func _ready():
	var file = File.new()
	
	
	if file.open("Dkb.settings",File.READ_WRITE) != 0:
		print("WELCOME")
		$Node2D/FileWindoe.popup(Rect2(-790,-429,1022,580))





func _on_settings_pressed():
	get_tree().change_scene("res://settings.tscn")




func _on_FileWindoe_dir_selected(dir):
	if not str(dir).ends_with("/"):
		Options.filepath = dir + "/"
	else:
		Options.filepath = dir
	Options._on_back_pressed()
