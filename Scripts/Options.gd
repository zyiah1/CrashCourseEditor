extends Node2D

var scrollbg = "true"
var colorbg = Color(0.3,0.6,0.3)
var filepath = "res://"
var autofull = false
var interval = 60
var firstboot = true


func _ready():
	if get_node_or_null("bfg") == null:
		if autofull == true:
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (true) else Window.MODE_WINDOWED
	#OS.set_window_size(OS.get_screen_size())
	if FileAccess.open("res://Dkb.settings",FileAccess.READ):
		var file = FileAccess.open("res://Dkb.settings", FileAccess.READ)
		var settings = file.get_as_text()
		
		settings = settings.split("\n")
		
		if settings[settings.size()-2] == "end": #retreive all the data
			Options.scrollbg = settings[0]
			var rgb = settings[1].lstrip("(").split(",")
			Options.colorbg = Color(float(rgb[0]),float(rgb[1]),float(rgb[2]))
			Options.filepath = settings[2]
			Options.interval = settings[3]
		
	if get_node_or_null("setting1") != null:
		if Options.scrollbg == "false":
			$setting1.button_pressed = false
		if Options.scrollbg == "true":
			$setting1.button_pressed = true
	if get_node_or_null("setting5/TextEdit") != null:
		$setting5/TextEdit.text = str(Options.interval)
		
		
		


func _on_back_pressed():
	var content = [Options.scrollbg,
	Options.colorbg,
	Options.filepath,
	Options.interval,
	"end"]
	
	var file = FileAccess.open("res://Dkb.settings", FileAccess.WRITE)
	for line in content:
		file.store_line(str(line))
	file.close()



func _on_setting1_pressed():
	if $setting1.button_pressed == false:
		Options.scrollbg = "false"
	if $setting1.button_pressed == true:
		Options.scrollbg = "true"








func _on_FileWindoe_dir_selected(dir):
	if str(dir).ends_with("/"):
		Options.filepath = dir
	else:
		Options.filepath = dir + "/"


func _on_TextEdit_text_changed():
	Options.interval = int($setting5/TextEdit.text)
