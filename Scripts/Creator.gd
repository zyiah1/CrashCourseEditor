extends Node2D

var saving = false
var item = "none"

const exit = preload("res://door.tscn")
const banana = preload("res://banana.tscn")
const checkpoint = preload("res://checkpoint.tscn")
const finalcheck = preload("res://finalcheckpoint.tscn")
const musicrail = preload("res://musicrail.tscn")
const Rail = preload("res://DefaultRail.tscn")
const InvisibleRail = preload("res://InvisibleRail.tscn")
const BlueRail = preload("res://BlueRail.tscn")
const RightSpin = preload("res://Rspin.tscn")
const LeftSpin = preload("res://Lspin.tscn")
const player = preload("res://player.tscn")
const coin = preload("res://coin.tscn")
const DK = preload("res://dk.tscn")
const Pauline = preload("res://pauline.tscn")

#Moving Platforms
const PathRail = preload("res://PathRail.tscn")
const fan = preload("res://FanMove.tscn")
const RightMove = preload("res://RMove.tscn")
const LeftMove = preload("res://LMove.tscn")
const AutoPlat = preload("res://AutoMove.tscn")
const EndMove = preload("res://EndMove.tscn")
const LeftCrank = preload("res://Lcrank.tscn")
const RightCrank = preload("res://Rcrank.tscn")

var idnum: int = 3
var mode: int = 1
var checkpoints: int = 0
var railplace: int = -2
var lineplacing: bool = true
var propertypanel: bool = false
var movingLoop: bool = false
var stored = null
var editednode = null
var filepath: String = Options.filepath

@onready var redtex = $CanvasLayer3/CanvasLayer2/rails/rail.icon
@onready var bluetex = $CanvasLayer3/CanvasLayer2/blue.icon
@onready var graytex = $CanvasLayer3/CanvasLayer2/invisible.icon
var arrow1 = preload("res://railart/Arrow.png")
var arrow2 = preload("res://railart/BigArrow.png")
var arrow3 = preload("res://railart/ArrowKaiten.png")
var arrow4 = preload("res://railart/arrow45.png")
var arrow5 = preload("res://railart/Arrow90.png")
var arrow6 = preload("res://railart/Arrow180.png")


signal EXPORT

@export var map: PackedStringArray = ["Version: 1",
"IsBigEndian: True",
"SupportPaths: False",
"HasReferenceNodes: False",
"root:",
"  LayerInfos:",
"    - Infos:",
"        ObjInfo:"]
var objects:PackedStringArray = []

var nodes = []
var history = []
var historyoffset = -1
var disabledcontrolls = false

func _ready():
	
	$nonmoving/save/Timer.wait_time = int(Options.interval+1)
	if Options.scrollbg == "false":
		$Animation.speed_scale = 1000
		$CanvasLayer3/CanvasLayer/buttons.speed_scale = 1000
	if Options.OSFileManager == "true":
		$CanvasLayer3/SaveAs.use_native_dialog = true
	#make the default borders of the level if new level
	if get_tree().current_scene.name == "Editor": #Not loading screen
		var borders = [InvisibleRail.instantiate(),InvisibleRail.instantiate(),InvisibleRail.instantiate(),InvisibleRail.instantiate()]
		borders[0].get_node("start").position = Vector2(495,-555)
		borders[0].get_node("end").position = Vector2(-495,-555)
		borders[1].get_node("start").position = Vector2(495,-555)
		borders[1].get_node("end").position = Vector2(495,555)
		borders[2].get_node("start").position = Vector2(-495,-555)
		borders[2].get_node("end").position = Vector2(-495,555)
		borders[3].get_node("start").position = Vector2(-495,555)
		borders[3].get_node("end").position = Vector2(495,555)
		for bridgeinst in borders:
			bridgeinst.loading = true
			connect("EXPORT", Callable(bridgeinst, "EXPORT"))
			add_child(bridgeinst)
			bridgeinst.newseg()
			bridgeinst.done()
	else:
		disabledcontrolls = true
		$Cam.position = Vector2.ZERO
		$Cam.zoom = Vector2(.75,.75)
		$Cam.paused = true
		$Cam.toggleUI()
	#connect all item and tool buttons
	for button in get_tree().get_nodes_in_group("button"):
		button.connect("selected",Callable(self,"itemselected"))


var bridgeheader:PackedStringArray = ["        RailInfos:",
"          PathInfo:"
]

var bridgedata:PackedStringArray = []

var end:PackedStringArray = ["      LayerName: LC",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L1",
"    - Infos:",
"        ObjInfo:",
"          - comment: !l -1",
"            dir_x: 0.00000",
"            dir_y: 0.00000",
"            dir_z: 0.00000",
"            id_name: obj3",
"            layer: L2",
"            link_info: []",
"            link_num: !l 0",
"            name: Dkb_BlackBoard01",
"            param0: -1.00000",
"            param1: -1.00000",
"            param10: -1.00000",
"            param11: -1.00000",
"            param2: -1.00000",
"            param3: -1.00000",
"            param4: -1.00000",
"            param5: -1.00000",
"            param6: -1.00000",
"            param7: -1.00000",
"            param8: -1.00000",
"            param9: -1.00000",
"            pos_x: 0.00000",
"            pos_y: 0.00000",
"            pos_z: 0.00000",
"            scale_x: 1.00000",
"            scale_y: 1.00000",
"            scale_z: 1.00000",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L2",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L3",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L4",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L5",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L6",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L7",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L8",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L9",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L10",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L11",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L12",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L13",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L14",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L15",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L16",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L17",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L18",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L19",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L20",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L21",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L22",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L23",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L24",
"    - Infos:",
"        ObjInfo: []",
"        RailInfos:",
"          PathInfo: []",
"      LayerName: L25"]


func _process(_delta):
	itemplace()
	shortcuts()

func itemselected(item_name):
	item = item_name

func itemplace():
	var instance = null
	if Input.is_action_just_pressed("bridge"):
		railplace -= 1
		if railplace == 0:
			Ain()
			railplace = -69
			return
		if lineplacing == true:
			
			railplace = 1
			if item == "rail":
				instance = Rail.instantiate()
				match mode:
					2:
						instance = BlueRail.instantiate()
					3:
						instance = InvisibleRail.instantiate()
			if item == "music":
				instance = musicrail.instantiate()
			if item == "endrotate":
				instance = preload("res://EndRotate.tscn").instantiate()
			if item == "Rspin":
				instance = RightSpin.instantiate()
			if item == "Lspin":
				instance = LeftSpin.instantiate()
			if item == "Lpivot":
				instance = preload("res://LRotate.tscn").instantiate()
			if item == "Rpivot":
				instance = preload("res://RRotate.tscn").instantiate()
			if item == "Apivot":
				instance = preload("res://AutoRotate.tscn").instantiate()
			if item == "LS":
				instance = preload("res://LSpivit.tscn").instantiate()
			if item == "RS":
				instance = preload("res://RSpivit.tscn").instantiate()
			if instance == null:
				railplace = 3
			if item.begins_with("moving"):
				instance = PathRail.instantiate()
			if item == "movingfan":
				instance.rail = fan
			if item == "movingR":
				instance.rail = RightMove
			if item == "movingL":
				instance.rail = LeftMove
			if item == "movingA":
				instance.rail = AutoPlat
			if item == "movingCrankL":
				instance.rail = LeftCrank
			if item == "movingCrankR":
				instance.rail = RightCrank
			if item == "movingEnd":
				instance.rail = EndMove
				instance.Param1 = 0
			if instance != null:
				add_child(instance)
				lineplacing = false
				out()
				connect("EXPORT", Callable(instance, "EXPORT"))
				nodes.append(instance)
				undolistadd({"Type":"Add","Node":instance})
				return
			
	if Input.is_action_just_pressed("bridge") or Input.is_action_pressed("control") and Input.is_action_pressed("bridge"):
		if item == "player":
			#$Animation.stop()
			$CanvasLayer3/CanvasLayer/buttons.play("out")
			item = "none"
			instance = player.instantiate()
			stored = instance
		if item == "banana":
			instance = banana.instantiate()
		if item == "1up":
			instance = preload("res://1up.tscn").instantiate()
		if item == "checkpoint":
			instance = checkpoint.instantiate()
			if checkpoints == 0:
				instance = preload("res://firstcheckpoint.tscn").instantiate()
			instance.Param2 = checkpoints
			checkpoints += 1
		if item == "final":
			instance = finalcheck.instantiate()
			instance.Param2 = checkpoints
			checkpoints += 1
		if  item == "coin":
			instance = coin.instantiate()
		if item == "door":
			instance = exit.instantiate()
		if item == "dk":
			instance = DK.instantiate()
		if item == "pauline":
			instance = Pauline.instantiate()
		if item == "hammer":
			instance = preload("res://hammer.tscn").instantiate()
		if item == "purse":
			instance = preload("res://purse.tscn").instantiate()
		if item == "barrel":
			instance = preload("res://barrel.tscn").instantiate()
		if item == "ladder":
			instance = preload("res://ladder.tscn").instantiate()
		if item == "arrow":
			instance = preload("res://Arrow.tscn").instantiate()
			if mode == 2:
				instance.ObjectName = "Dkb_ChalkYajirushi_Arrow"
			if mode == 3:
				instance.ObjectName = "Dkb_ChalkYajirushi_Kaiten"
		if item == "arrow2":
			instance = preload("res://Arrow.tscn").instantiate()
			instance.ObjectName = "Dkb_ChalkYajirushi_45"
			if mode == 2:
				instance.ObjectName = "Dkb_ChalkYajirushi_90"
			if mode == 3:
				instance.ObjectName = "Dkb_ChalkYajirushi_180"
		if instance != null:
			instance.position = get_global_mouse_position().round()
			add_child(instance)
			nodes.append(instance)
			undolistadd({"Type":"Add","Node":instance})
			connect("EXPORT", Callable(instance, "EXPORT"))



func undolistadd(dictionary):
	if not history.size()+historyoffset == history.size()-1: #then there's nothing after this point in history
		print("Remove Future")
		while historyoffset < -1:
			history.remove_at(history.size()-1)
			historyoffset += 1
		historyoffset = -1
		for node in get_tree().get_nodes_in_group("Limbo"):
			node.queue_free() #gets rid of hidden "deleted" objects that wont be used
	history.append(dictionary)

func delete(node:Node):
	node.hide()
	node.add_to_group("Limbo")
	if node.is_in_group("player"): #if we redo the player, show the icon
		playerunstore()
		print("A")

func readd(node:Node):
	node.show()
	node.remove_from_group("Limbo")
	if node.is_in_group("player"): #if we undo the player, hide the icon
		playerstore()
		

func redo():
	if historyoffset >= -1: #cant redo more than the end
		print("No Further Redo History")
		return
	historyoffset += 1
	var currenthistory = history[history.size()+historyoffset]
	match currenthistory.Type:
		"Add":
			readd(currenthistory.Node)
		"Delete":
			delete(currenthistory.Node)
		"Move":
			print("Redo movedo")
			currenthistory.Node.position = currenthistory.Data[1]

func undo():
	if history.size() < -historyoffset: #cant undo more than the start
		print("No Previous Undo History")
		return
	
	var currenthistory = history[history.size()+historyoffset]
	match currenthistory.Type:
		"Add":
			if lineplacing == false: #special undo if you are currently placing a rail
				currenthistory.Node.queue_free()
				lineplacing = true
				history.erase(currenthistory)
				Ain()
				return
			delete(currenthistory.Node)
		"Delete":
			readd(currenthistory.Node)
		"Move":
			currenthistory.Node.position = currenthistory.Data[0]
	historyoffset -= 1

func shortcuts():
	if not disabledcontrolls:
		if Input.is_action_just_pressed("id"):
			movingLoop = not movingLoop
		if Input.is_action_just_pressed("redo"):
			redo()
		elif Input.is_action_just_pressed("undo"):
			undo()
		if Input.is_action_just_pressed("esc"):
			if $"CanvasLayer3/Proporties Panel".visible == false:
				get_tree().change_scene_to_file("res://Loader.tscn")
			else:
				$"CanvasLayer3/Proporties Panel/ScrollContainer/VBox"._on_new_pressed()
		if Input.is_action_just_pressed("Export"):
			save()
			OS.shell_open(str("file://" + filepath + $nonmoving/name.text + ".txt"))
		if Input.is_action_just_pressed("save"):
			save()
		if Input.is_action_just_pressed("Save As"):
			saveas()
		if Input.is_action_just_pressed("Copy"):
			copy()
		if Input.is_action_just_pressed("shift"):
			mode += 1
			if mode == 4:
				mode = 1
			if mode == 1:
				$CanvasLayer3/CanvasLayer2/rails/rail.icon = redtex
				$CanvasLayer3/CanvasLayer2/objects/arrow.icon = arrow1
				$CanvasLayer3/CanvasLayer2/objects/arrow2.icon = arrow4
			if mode == 2:
				$CanvasLayer3/CanvasLayer2/rails/rail.icon = bluetex
				$CanvasLayer3/CanvasLayer2/objects/arrow.icon = arrow2
				$CanvasLayer3/CanvasLayer2/objects/arrow2.icon = arrow5
			if mode == 3:
				$CanvasLayer3/CanvasLayer2/rails/rail.icon = graytex
				$CanvasLayer3/CanvasLayer2/objects/arrow.icon = arrow3
				$CanvasLayer3/CanvasLayer2/objects/arrow2.icon = arrow6

var namefocus = false

func saveas():
	$CanvasLayer3/SaveAs.popup_centered()
	$CanvasLayer3/SaveAs.current_dir = filepath
	get_tree().paused = true

func save():
	if namefocus == false:
		if saving == false:
			
			
			saving = true
			$nonmoving/saving.show()
			objects = []
			bridgedata = []
			emit_signal("EXPORT")
			var file = FileAccess.open(filepath + $nonmoving/name.text + ".txt", FileAccess.WRITE)
			var __my_text = map + objects + bridgeheader + bridgedata + end
			
			
			for line2 in __my_text:
				file.store_line(line2)
			file.close()
			$nonmoving/delay.start()
			bridgedata = []
			objects = []
			saving = false

func copy():
	save()
	var file = FileAccess.open(filepath + $nonmoving/name.text + ".txt", FileAccess.READ)
	DisplayServer.clipboard_set(file.get_as_text())





func out():
	if stored == null:
		$Animation.play("Out2")
	else:
		$Animation.play("Out1")
		


func Ain():
	if stored == null:
		$Animation.play("In2")
	else:
		$Animation.play("In1")
		


func _on_Timer_timeout():
	save()


func _on_delay_timeout():
	$nonmoving/saving.hide()


func _on_name_focus_entered():
	namefocus = true


func _on_name_focus_exited():
	namefocus = false

func playerunstore():
	$Animation.play("RESET")
	$CanvasLayer3/CanvasLayer/buttons.play("in")
	$CanvasLayer3/CanvasLayer/Control/player.disabled = false
	stored = null

func playerstore():
	$CanvasLayer3/CanvasLayer/buttons.play("out")
	$CanvasLayer3/CanvasLayer/Control/player.disabled = true
	for node in get_tree().get_nodes_in_group("player"):
		if node.visible:
			stored = node

var Groupnum = 0

func parse(data):
	for line in data:
		var Edit = preload("res://LineEdit.tscn").instantiate()
		Edit.text = line
		match Groupnum:
			0:
				Edit.add_to_group("Data")
			1:
				Edit.add_to_group("End")
			2:
				Edit.add_to_group("ChildData")
			3:
				Edit.add_to_group("ChildEnd")
		$"CanvasLayer3/Proporties Panel/ScrollContainer/VBox".add_child(Edit)
		#Edit.connect("text_changed",Callable($"CanvasLayer3/Proporties Panel","datachanged"))
		Edit.connect("text_set",Callable($"CanvasLayer3/Proporties Panel","datachanged"))
		
	Groupnum += 1
	if Options.scrollbg == "true":
		$"CanvasLayer3/Proporties Panel/Panel".play("IN")
	else:
		$"CanvasLayer3/Proporties Panel".show()


func _on_view_index_pressed(index):
	#0 Hide UI
	#1 Loop Movements
	#2 Whole Level View
	if not disabledcontrolls:
		match index:
			0:
				if $Cam.paused == false and propertypanel == false:
					$Cam.toggleUI()
			1:
				movingLoop = not movingLoop
			2:
				$Cam.toggleCam()


func _on_file_index_pressed(index):
	#0 = Save
	#1 = Save as
	#2 = Copy
	#4 = Open In File Manager
	#5 = Show In File Manager
	#7 = Save And Quit
	if not disabledcontrolls:
		match index:
			0:
				save()
			1:
				saveas()
			2:
				copy()
			4:
				Input.action_press("Export")
			5:
				save()
				OS.shell_show_in_file_manager(str("file://" + filepath + $nonmoving/name.text + ".txt"))
			7:
				save()
				get_tree().quit()

func _on_edit_index_pressed(index):
	if not disabledcontrolls:
		match index:
			0:
				undo()
			1:
				redo()

func _on_help_index_pressed(_index):
	#0 = controls, 1 = tutorial for now the same
	$CanvasLayer3/Controls.show()


func _on_save_as_file_selected(_path):
	var text = $CanvasLayer3/SaveAs.current_file.erase($CanvasLayer3/SaveAs.current_file.length()-4,4)
	if text.ends_with(".txt"):
		text = text.erase(text.length()-4,4)
	$nonmoving/name.text = text
	print($nonmoving/name.text)
	filepath = $CanvasLayer3/SaveAs.current_dir + "/"
	save()
	get_tree().paused = false


func _on_save_as_canceled():
	get_tree().paused = false


func _on_save_as_confirmed():
	_on_save_as_file_selected("")


func _on_button_pressed():
	$CanvasLayer3/Controls.hide()
