extends Node2D

var saving = false
var item = "none"

const exit = preload("res://door.tscn")
const banana = preload("res://banana.tscn")
const checkpoint = preload("res://checkpoint.tscn")
const finalcheck = preload("res://finalcheckpoint.tscn")
const musicrail = preload("res://musicrail.tscn")
const bridge = preload("res://bridge.tscn")
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
const LeftCrank = preload("res://lcrank.tscn")
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

var disabledcontrolls = false

func _ready():
	
	$nonmoving/save/Timer.wait_time = int(Options.interval)
	if Options.scrollbg == "false":
		$Animation.speed_scale = 1000
		$CanvasLayer3/CanvasLayer/buttons.speed_scale = 1000
	
	#make the default borders of the level if new level
	if get_tree().current_scene.name == "Editor": #Not loading screen
		var borders = [bridge.instantiate(),bridge.instantiate(),bridge.instantiate(),bridge.instantiate()]
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
			bridgeinst.invisible = true
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


func _process(delta):
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
				instance = bridge.instantiate()
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
			if instance != null:
				add_child(instance)
				lineplacing = false
				out()
				connect("EXPORT", Callable(instance, "EXPORT"))
				nodes.append(instance)
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
				instance.first = true
				instance.changetofirst()
		if item == "final":
			instance = finalcheck.instantiate()
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
				instance.type = "big"
			if mode == 3:
				instance.type = "rotate"
		if item == "arrow2":
			instance = preload("res://Arrow.tscn").instantiate()
			instance.type = "45"
			if mode == 2:
				instance.type = "90"
			if mode == 3:
				instance.type = "180"
		if instance != null:
			instance.position = get_global_mouse_position().round()
			add_child(instance)
			nodes.append(instance)
			connect("EXPORT", Callable(instance, "EXPORT"))





func shortcuts():
	if not disabledcontrolls:
		if Input.is_action_just_pressed("id"):
			movingLoop = not movingLoop
		if Input.is_action_just_pressed("undo"):
			if nodes.size() != 0:
				if nodes[nodes.size() - 1] == stored: #if we undo the player, call the animation
					playerunstore()
					print("woah")
				
				var target = str(nodes[nodes.size() - 1])
				print("Undid ",target)
				
				nodes[nodes.size() - 1].queue_free()
				nodes.remove_at(nodes.size() - 1)
		if Input.is_action_just_pressed("esc"):
			if $"CanvasLayer3/Proporties Panel".visible == false:
				get_tree().change_scene_to_file("res://Loader.tscn")
			else:
				$"CanvasLayer3/Proporties Panel/ScrollContainer/VBox"._on_new_pressed()
		if Input.is_action_just_pressed("Export"):
			_on_Button_pressed()
			OS.shell_open(str("file://" + Options.filepath + $nonmoving/name.text + ".txt"))
		if Input.is_action_just_pressed("save"):
			_on_Button_pressed()
		if Input.is_action_just_pressed("Copy"):
			_on_Button_pressed()
			var file = FileAccess.open(Options.filepath + $nonmoving/name.text + ".txt", FileAccess.READ)
			
			
			
			DisplayServer.clipboard_set(file.get_as_text())
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

func _on_Button_pressed():
	if namefocus == false:
		if saving == false:
			
			
			saving = true
			$nonmoving/saving.show()
			objects = []
			bridgedata = []
			emit_signal("EXPORT")
			var file = FileAccess.open(Options.filepath + $nonmoving/name.text + ".txt", FileAccess.WRITE)
			var __my_text = map + objects + bridgeheader + bridgedata + end
			
			
			for line2 in __my_text:
				file.store_line(line2)
			file.close()
			$nonmoving/delay.start()
			bridgedata = []
			objects = []
			saving = false








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
	_on_Button_pressed()


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
