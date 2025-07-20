extends Node2D

var scrollbg = "true"
var colorbg = Color(0.3,0.6,0.3)
var filepath = "res://"
var interval = 60


func _ready():
	if Options.scrollbg == "false":
		$Buttons/setting1.button_pressed = false
	if Options.scrollbg == "true":
		$Buttons/setting1.button_pressed = true
		
	$Buttons/setting5/TextEdit.text = str(Options.interval)
	if Options.OSFileManager == "false":
		$Buttons/setting6.button_pressed = false
	if Options.OSFileManager == "true":
		$Buttons/setting6.button_pressed = true
	
	


func _on_back_pressed():
	Options.save()



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

func _on_setting_4_pressed():
	$Buttons/setting4/Node2D/FileWindoe.popup(Rect2(-790,-429,1022,580))

func _on_setting_6_pressed():
	if $Buttons/setting6.button_pressed == false:
		Options.OSFileManager = "false"
	if $Buttons/setting6.button_pressed == true:
		Options.OSFileManager = "true"
