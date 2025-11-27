extends Button

@export var top_row = true
@export var delete = true
@export var left = true

func _ready():
	connect("pressed",Callable(get_parent(),"layout_control_pressed").bind(self))
	
