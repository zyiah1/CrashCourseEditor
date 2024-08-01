extends Button



func _on_help_pressed():
	$Sprite2D.visible = not $Sprite2D.visible


func _on_LinkButton_pressed():
	OS.shell_open("https://youtu.be/gzPDyb5eMCs")


func _on_close_pressed():
	$Sprite2D.visible = false
