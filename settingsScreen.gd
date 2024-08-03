extends Node2D

var scrollbg = "true"
var colorbg = Color(0.3,0.6,0.3)
var filepath = "res://"
var interval = 60


func _ready():
	if get_node_or_null("Buttons/setting1") != null:
		if Options.scrollbg == "false":
			$Buttons/setting1.button_pressed = false
		if Options.scrollbg == "true":
			$Buttons/setting1.button_pressed = true
	if get_node_or_null("setting5/TextEdit") != null:
		$Buttons/setting5/TextEdit.text = str(Options.interval)
		
		
		


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
	if $Buttons/setting1.button_pressed == false:
		Options.scrollbg = "false"
	if $Buttons/setting1.button_pressed == true:
		Options.scrollbg = "true"








func _on_FileWindoe_dir_selected(dir):
	if str(dir).ends_with("/"):
		Options.filepath = dir
	else:
		Options.filepath = dir + "/"


func _on_TextEdit_text_changed():
	Options.interval = int($Buttons/setting5/TextEdit.text)
