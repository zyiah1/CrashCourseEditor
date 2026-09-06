extends Node2D

var Editor = null

#options
var scrollbg: String = "true"
var colorbg = Color(0.3,0.6,0.3)
var filepath: String = "res://"
var interval: int = 60
var OSFileManager: String = "true"
var CheckForUpdates: String = "true"
var keybindings:Dictionary = {}
var layout: String = "custom"
var custom_layout = []#["player","blue"]#["blue",["Arrow","BigArrow","ArrowKaiten","Arrow45","Arrow90","Arrow180"],"banana","checkpoint","finalcheckpoint","dk","movingEnd","row2","rail","Lpivot","player"]


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
			Options.CheckForUpdates = settings[5]
		if CheckForUpdates == "end" or CheckForUpdates == "":
			CheckForUpdates = "true"
		print(CheckForUpdates)
	if FileAccess.open("res://DkbInput.settings",FileAccess.READ):
		var file = FileAccess.open("res://DkbInput.settings", FileAccess.READ)
		var getthings = file.get_var()
		print(getthings)
		if getthings is Dictionary:
			keybindings = getthings
		#set_keybinds()
		print(keybindings)


func save():
	var content = [Options.scrollbg,
	Options.colorbg,
	Options.filepath,
	Options.interval,
	Options.OSFileManager,
	Options.CheckForUpdates,
	"end"]
	
	var file = FileAccess.open("res://Dkb.settings", FileAccess.WRITE)
	for line in content:
		file.store_line(str(line))
	file.close()
	store_keybinds()
	var file2 = FileAccess.open("res://DkbInput.settings", FileAccess.WRITE)
	for line in content:
		file2.store_var(keybindings)
	file2.close()

func store_keybinds():
	var dict = {}
	var actions = InputMap.get_actions()
	
	for input in actions:
		if !input.begins_with("ui_"):
			dict[input] = InputMap.action_get_events(input)[0]
			print(input)
	keybindings = dict
	print(dict)

func set_keybinds():
	var dict: Dictionary = keybindings
	if keybindings.size() < 20:
		return
	for input in dict:
		InputMap.erase_action(input)
		InputMap.add_action(dict.get(input))
