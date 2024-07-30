extends Button



func _on_help_pressed():
	$Sprite.visible = not $Sprite.visible


func _on_LinkButton_pressed():
	OS.shell_open("https://youtu.be/gzPDyb5eMCs")


func _on_close_pressed():
	$Sprite.visible = false


func _on_bug_pressed():
	OS.shell_open("https://forms.gle/59n4zZzmYVyBDicv8")
