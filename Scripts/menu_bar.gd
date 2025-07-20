extends MenuBar

func _ready():
	if is_native_menu():
		position.y -= 9999 #stop from blocking UI if its invisible anyway
