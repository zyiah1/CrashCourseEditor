extends Node2D

var Editor = null

#options
var scrollbg: String = "true"
var colorbg = Color(0.3,0.6,0.3)
var filepath: String = "res://"
var interval: int = 60
var OSFileManager: String = "true"
var layout: String = "default"
var custom_layout = []#["blue",["Arrow","BigArrow","ArrowKaiten","Arrow45","Arrow90","Arrow180"],"banana","checkpoint","finalcheckpoint","dk","movingEnd"]#,"row2","rail","Lpivot","player"]

#var autofull: bool = false
var firstboot = true

func _ready():
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
			Options.OSFileManager = settings[4]
		

func save():
	var content = [Options.scrollbg,
	Options.colorbg,
	Options.filepath,
	Options.interval,
	Options.OSFileManager,
	"end"]
	
	var file = FileAccess.open("res://Dkb.settings", FileAccess.WRITE)
	for line in content:
		file.store_line(str(line))
	file.close()
