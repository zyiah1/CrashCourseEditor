extends MenuBar

func _ready():
	if is_native_menu():
		position.y -= 9999 #stop from blocking UI if its invisible anyway
	else:
		get_parent().get_node("CanvasLayer2").offset.y = 30
		owner.get_node("nonmoving").offset.y = 30
