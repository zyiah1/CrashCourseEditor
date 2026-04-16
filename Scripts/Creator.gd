extends Node2D

var saving = false
var item = "none"

const exit = preload("res://Objects/door.tscn")
const banana = preload("res://Objects/banana.tscn")
const checkpoint = preload("res://Objects/checkpoint.tscn")
const finalcheck = preload("res://Objects/finalcheckpoint.tscn")
const musicrail = preload("res://musicrail.tscn")
const DefaultRail = preload("res://DefaultRail.tscn")
const InvisibleRail = preload("res://InvisibleRail.tscn")
const BlueRail = preload("res://BlueRail.tscn")
const RightSpin = preload("res://Rspin.tscn")
const LeftSpin = preload("res://Lspin.tscn")
const player = preload("res://Objects/player.tscn")
const coin = preload("res://Objects/coin.tscn")
const DK = preload("res://Objects/dk.tscn")
const Pauline = preload("res://Objects/pauline.tscn")

#Moving Platforms
const path_rail = preload("res://PathRail.tscn")
const fan = preload("res://FanMove.tscn")
const RightMove = preload("res://RMove.tscn")
const LeftMove = preload("res://LMove.tscn")
const AutoPlat = preload("res://AutoMove.tscn")
const EndMove = preload("res://EndMove.tscn")
const LeftCrank = preload("res://Lcrank.tscn")
const RightCrank = preload("res://Rcrank.tscn")

var idnum: int = 3
var checkpoints = []
var railplace: int = -2
var lineplacing: bool = true
var propertypanel: bool = false
var movingLoop: bool = false
var stored = null
var editednode = null
var filepath: String = Options.filepath
var roundedmousepos: Vector2

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

var history = []
var historyoffset = -1
var disabledcontrolls = false
var grid:float = 1.0

func _ready():
	Options.Editor = self
	$nonmoving/save/Timer.wait_time = int(Options.interval+1)
	if Options.scrollbg == "false":
		$Animation.speed_scale = 1000
		$Player.speed_scale = 1000
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
			bridgeinst.idnum = idnum #they dont define it because they are set to loading
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
	
	#change layout
	if Options.custom_layout != [] and Options.layout == "custom":
		await loadlayout(Options.custom_layout)
	if Options.layout == "compact":
		pass
	if Options.layout == "expanded":
		loadlayout(["player","banana","checkpoint","finalcheckpoint","coin","1up","door","barrel","ladder","purse","hammer","Arrow","Arrow45","Arrow90","Arrow180","ArrowKaiten","BigArrow","pauline","dk","row2","rail","blue","invisible","music","movingfan","movingL","movingR","movingA","movingCrankL","movingCrankR","Lspin","Rspin","Lpivot","Rpivot","Apivot","tiltLS","tiltRS","movingEnd","endrotate"])
	if Options.layout == "onerow":
		loadlayout(["player","banana","checkpoint","finalcheckpoint","coin","1up","door","barrel","ladder","purse","hammer","Arrow","Arrow45","Arrow90","Arrow180","ArrowKaiten","BigArrow","pauline","dk","rail","blue","invisible","music","movingfan","movingL","movingR","movingA","movingCrankL","movingCrankR","Lspin","Rspin","Lpivot","Rpivot","Apivot","tiltLS","tiltRS","movingEnd","endrotate"])
	
	for node in get_tree().get_nodes_in_group("button"):
		node.startup() #trigger start of each button
	
	#connect all item and tool buttons
	for button in get_tree().get_nodes_in_group("button"):
		button.connect("selected",Callable(self,"itemselected"))

func loadlayout(layout_data:Array):
	for node in get_tree().get_nodes_in_group("button"):
		if node.get_parent() != $CanvasLayer3/CanvasLayer2/Buttons/tools:# and not node.is_in_group("playerbutton"):
			node.hide()
			if not node.is_in_group("playerbutton"):
				node.name = "buffer" #no name problems
	get_tree().get_first_node_in_group("playerbutton").get_parent().reparent($CanvasLayer3)
	var id = 0
	var row = $CanvasLayer3/CanvasLayer2/Buttons/objects
	for part in layout_data:
		if row.get_children().size() <= id: #if there isn't enough buttons,
			row.add_child(row.get_child(row.get_children().size()-1).duplicate())
		var currentbutton = row.get_child(id)
		
		if part is Array:
			currentbutton.name = part[0]
			part.remove_at(0)
			currentbutton.additional_names = part
			currentbutton.show()
		elif part is String: #then 
			if part == "row2":
				#start new row
				row = $CanvasLayer3/CanvasLayer2/Buttons/rails
				id = 0
			elif part == "none":
				var control = Control.new()
				control.size_flags_horizontal = Control.SIZE_EXPAND
				control.mouse_filter = Control.MOUSE_FILTER_IGNORE
				row.add_child(control)
				row.move_child(control,id)
			elif part != "player":
				currentbutton.name = part
				currentbutton.show()
			if part == "player":
				if row == $CanvasLayer3/CanvasLayer2/Buttons/objects:
					var playerbutton = get_tree().get_first_node_in_group("playerbutton").get_parent()
					get_tree().get_first_node_in_group("playerbutton").show()
					playerbutton.reparent(row)
					row.move_child(playerbutton,id)
				else:
					currentbutton.name = part
					currentbutton.show()
					currentbutton.add_to_group("playerbutton")
		id += 1
	if get_tree().get_first_node_in_group("playerbutton").visible == false:
		get_tree().get_first_node_in_group("playerbutton").get_parent().queue_free()
	if not layout_data.has("row2"):
		$CanvasLayer3/CanvasLayer2/Buttons/tools.position.y = 72
	
	return

var bridgeheader:PackedStringArray = ["        RailInfos:",
"          PathInfo:"
]

var bridgedata:PackedStringArray = []

#region End Of Level Empty Layer Data
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
#endregion


func _process(_delta):
	itemplace()
	shortcuts()
	if item == "toolmove" and Input.is_action_pressed("usetool"):
		$Cam.paused = true
	if Input.is_action_just_released("usetool") and not $nonmoving/name.has_focus() and not $nonmoving/grid.has_focus():
		$Cam.paused = false
	if get_viewport(): 
		if $nonmoving/gridenabled.button_pressed:
			roundedmousepos = ((get_global_mouse_position()/grid).round())*grid
		else:
			roundedmousepos = get_global_mouse_position()

func itemselected(item_name):
	item = item_name

func itemplace():
	var instance = null
	if item == "multiselect" and Input.is_action_just_pressed("usetool"):
		instance = preload("res://multiselect.tscn").instantiate()
		instance.position = get_global_mouse_position().round()
		add_child(instance)
	if Input.is_action_just_pressed("bridge"):
		railplace -= 1
		if railplace == 0:
			Ain()
			railplace = -69
			return
		if lineplacing == true:
			
			railplace = 1
			if item == "rail":
				instance = DefaultRail.instantiate()
			if item == "blue":
				instance = BlueRail.instantiate()
			if item == "invisible":
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
			if item == "tiltLS":
				instance = preload("res://LSpivit.tscn").instantiate()
			if item == "tiltRS":
				instance = preload("res://RSpivit.tscn").instantiate()
			if instance == null:
				railplace = 3
			if item.begins_with("moving"):
				instance = path_rail.instantiate()
			if item == "movingfan":
				instance.railscene = fan
			if item == "movingR":
				instance.railscene = RightMove
			if item == "movingL":
				instance.railscene = LeftMove
			if item == "movingA":
				instance.railscene = AutoPlat
			if item == "movingCrankL":
				instance.railscene = LeftCrank
			if item == "movingCrankR":
				instance.railscene = RightCrank
			if item == "movingEnd":
				instance.railscene = EndMove
				instance.Param1 = "0"
			if instance != null:
				$Cam.railplacing = true
				$Cam.shiftmode = false
				add_child(instance)
				lineplacing = false
				out()
				connect("EXPORT", Callable(instance, "EXPORT"))
				undolistadd({"Type":"Add","Node":instance})
				return
			
	if Input.is_action_just_pressed("bridge") or Input.is_action_pressed("control") and Input.is_action_pressed("bridge"):
		match item:
			"player":
				#$Animation.stop()
				if $CanvasLayer3/CanvasLayer2/Buttons/objects.get_child(0).name == "Control":
					$Player.play("out")
				item = "none"
				instance = player.instantiate()
				stored = instance
			"banana":
				instance = banana.instantiate()
			"1up":
				instance = preload("res://Objects/1up.tscn").instantiate()
			"checkpoint":
				instance = checkpoint.instantiate()
				if checkpoints.size() == 0:
					instance = preload("res://Objects/firstcheckpoint.tscn").instantiate()
				var area = 0
				for value in checkpoints:
					if area in checkpoints:
						area += 1
				instance.Param2 = area
				checkpoints.append(area)
			"finalcheckpoint":
				instance = finalcheck.instantiate()
				var area = 0
				for value in checkpoints:
					if area in checkpoints:
						area += 1
				instance.Param2 = area
				checkpoints.append(area)
			"coin":
				instance = coin.instantiate()
			"door":
				instance = exit.instantiate()
			"dk":
				instance = DK.instantiate()
			"pauline":
				instance = Pauline.instantiate()
			"hammer":
				instance = preload("res://Objects/hammer.tscn").instantiate()
			"purse":
				instance = preload("res://Objects/purse.tscn").instantiate()
			"barrel":
				instance = preload("res://Objects/barrel.tscn").instantiate()
			"ladder":
				instance = preload("res://Objects/ladder.tscn").instantiate()
			"Arrow":
				instance = preload("res://Objects/Arrow.tscn").instantiate()
			"BigArrow":
				instance = preload("res://Objects/Arrow.tscn").instantiate()
				instance.ObjectName = "Dkb_ChalkYajirushi_Arrow"
			"ArrowKaiten":
				instance = preload("res://Objects/Arrow.tscn").instantiate()
				instance.ObjectName = "Dkb_ChalkYajirushi_Kaiten"
			"Arrow45":
				instance = preload("res://Objects/Arrow.tscn").instantiate()
				instance.ObjectName = "Dkb_ChalkYajirushi_45"
			"Arrow90":
				instance = preload("res://Objects/Arrow.tscn").instantiate()
				instance.ObjectName = "Dkb_ChalkYajirushi_90"
			"Arrow180":
				instance = preload("res://Objects/Arrow.tscn").instantiate()
				instance.ObjectName = "Dkb_ChalkYajirushi_180"
		if instance != null:
			instance.position = roundedmousepos
			add_child(instance)
			undolistadd({"Type":"Add","Node":instance})
			connect("EXPORT", Callable(instance, "EXPORT"))



func undolistadd(dictionary):
	if not history.size()+historyoffset == history.size()-1: #then there's nothing after this point in history
		var deletedhistory = []
		print("Remove Future")
		while historyoffset < -1:
			deletedhistory.append(history[history.size()-1])
			history.remove_at(history.size()-1)
			historyoffset += 1
		historyoffset = -1
		for part in deletedhistory:
			if part.Type == "Add":
				if part.Node.is_in_group("Limbo"):
					part.Node.queue_free() #gets rid of hidden "deleted" objects that wont be used
	history.append(dictionary)

func delete(node:Node):
	node.hide()
	node.add_to_group("Limbo")
	if node.is_in_group("player"): #if we redo the player, show the icon
		playerunstore()
	if node.is_in_group("checkpoint"): #if we redo the player, show the icon
		checkpoints.erase(int(node.data[13].erase(0,20)))
		


func readd(node:Node):
	node.show()
	node.remove_from_group("Limbo")
	if node.is_in_group("player"): #if we undo the player, hide the icon
		playerstore()
		

func redo():
	$fade.stop()
	$fade.play("undofade")
	if historyoffset >= -1: #cant redo more than the end
		$nonmoving/undo.text = "No Further Redo History"
		return
	historyoffset += 1
	var currenthistory = history[history.size()+historyoffset]
	$nonmoving/undo.text = "Redid "+currenthistory.Type
	var currentnode = currenthistory.Node
	match currenthistory.Type:
		"Add":
			readd(currentnode)
		"Delete":
			delete(currentnode)
		"DeletePoint":
			currentnode.remove_point(currenthistory.PointID)
		"Transform":
			currentnode.transform = currenthistory.Data[1]
		"TransformPoint":
			var point = currentnode.points[currenthistory.PointID]
			point.position = currenthistory.Data[1]
			point.set_data()
			if currentnode is PathRail: #then dont set rail
				currentnode.change_points(currentnode.points,currentnode.get_node("start"),currentnode.get_node("end"))
			else:
				currentnode.rail.points = currentnode.change_points(currentnode.points,currentnode.get_node("start"),currentnode.get_node("end")) #set the rail visual back
		"Property":
			currentnode.data = currenthistory.Data[1]
			currentnode.reposition()
		"PropertyRail":
			currentnode.set_point_data(currenthistory.Data[1])
			currentnode.end = currenthistory.Data[3]
			currentnode.reposition()
		"PropertyMoveRail":
			currentnode.set_point_data(currenthistory.Data[1])
			currentnode.end = currenthistory.Data[3]
			currentnode.childrail.set_point_data(currenthistory.Data[5])
			currentnode.childrail.endplat = currenthistory.Data[7]
			currentnode.reposition()

func undo():
	$fade.stop()
	$fade.play("undofade")
	if history.size() < -historyoffset: #cant undo more than the start
		$nonmoving/undo.text = "No Previous Undo History"
		return
	
	var currenthistory = history[history.size()+historyoffset]
	$nonmoving/undo.text = "Undid "+currenthistory.Type
	var currentnode = currenthistory.Node
	match currenthistory.Type:
		"Add":
			if lineplacing == false: #special undo if you are currently placing a rail
				currentnode.queue_free()
				lineplacing = true
				history.erase(currenthistory) #removes rail adding from the history
				Ain()
				railplace = -1
				return
			delete(currentnode)
		"Delete":
			readd(currentnode)
		"DeletePoint":
			currentnode.add_point(currenthistory.PointID)
			currentnode.set_point_data(currenthistory.Data)
			if currentnode is PathRail: #then dont set rail
				currentnode.change_points(currentnode.points,currentnode.get_node("start"),currentnode.get_node("end"))
			else:
				currentnode.rail.points = currentnode.change_points(currentnode.points,currentnode.get_node("start"),currentnode.get_node("end"))
			if currentnode is RotatingRail:
				currentnode.rotationpoint = currenthistory.RotationPoint
				currentnode.changepivotpoint()
		"Transform":
			currentnode.transform = currenthistory.Data[0]
		"TransformPoint":
			var point = currentnode.points[currenthistory.PointID]
			point.position = currenthistory.Data[0]
			point.set_data()
			if currentnode is PathRail: #then dont set rail
				currentnode.change_points(currentnode.points,currentnode.get_node("start"),currentnode.get_node("end"))
			else:
				currentnode.rail.points = currentnode.change_points(currentnode.points,currentnode.get_node("start"),currentnode.get_node("end")) #set the rail visual back
		"Property":
			currentnode.data = currenthistory.Data[0]
			currentnode.reposition()
		"PropertyRail":
			currentnode.set_point_data(currenthistory.Data[0])
			currentnode.end = currenthistory.Data[2]
			currentnode.reposition()
		"PropertyMoveRail":
			currentnode.set_point_data(currenthistory.Data[0])
			currentnode.end = currenthistory.Data[2]
			currentnode.childrail.set_point_data(currenthistory.Data[4])
			currentnode.childrail.endplat = currenthistory.Data[6]
			currentnode.reposition()
	historyoffset -= 1

func shortcuts():
	if not disabledcontrolls and not $nonmoving/name.has_focus() and not $nonmoving/grid.has_focus():
		if Input.is_action_just_pressed("Loop"):
			movingLoop = not movingLoop
		if Input.is_action_just_pressed("ToggleGrid") and not propertypanel:
			$nonmoving/gridenabled.button_pressed = not $nonmoving/gridenabled.button_pressed
			_on_gridenabled_pressed()
		if Input.is_action_just_pressed("redo"):
			redo()
		elif Input.is_action_just_pressed("undo"):
			undo()
		elif Input.is_action_just_pressed("Transform") and not Input.is_action_pressed("redo"):
			get_tree().get_first_node_in_group("Transform")._pressed()
		if Input.is_action_just_pressed("Delete"):
			get_tree().get_first_node_in_group("Delete")._pressed()
		
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
		elif Input.is_action_just_pressed("Edit"):
			get_tree().get_first_node_in_group("Edit")._pressed()
		elif Input.is_action_just_pressed("Property"):
			get_tree().get_first_node_in_group("Property")._pressed()


var namefocus = false

func saveas():
	$CanvasLayer3/SaveAs.current_dir = filepath
	$CanvasLayer3/SaveAs.popup_centered()
	get_tree().paused = true

func save():
	if namefocus == false:
		if saving == false:
			
			
			if FileAccess.open((filepath + $nonmoving/name.text + ".txt"), FileAccess.WRITE):
				saving = true
				$SaveMessage.play("saving")
				objects = []
				bridgedata = []
				emit_signal("EXPORT")
				var file = FileAccess.open(filepath + $nonmoving/name.text + ".txt", FileAccess.WRITE)
				var __my_text = map + objects + bridgeheader + bridgedata + end
				
				
				for line2 in __my_text:
					file.store_line(line2)
				file.close()
				$SaveMessage.play("saved")
				bridgedata = []
				objects = []
				saving = false

func copy():
	save()
	var file = FileAccess.open(filepath + $nonmoving/name.text + ".txt", FileAccess.READ)
	DisplayServer.clipboard_set(file.get_as_text())
	$SaveMessage.play("copied")




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


func _on_name_focus_entered():
	namefocus = true


func _on_name_focus_exited():
	namefocus = false
	$nonmoving/name.text = $nonmoving/name.text.replace("/",'|')

func playerunstore():
	if $CanvasLayer3/CanvasLayer2/Buttons/objects.get_child(0).name == "Control":
		$Player.play("in")
	get_tree().get_first_node_in_group("playerbutton").disabled = false
	stored = null

func playerstore():
	if $CanvasLayer3/CanvasLayer2/Buttons/objects.get_child(0).name == "Control":
		$Player.play("out")
	get_tree().get_first_node_in_group("playerbutton").disabled = true
	for node in get_tree().get_nodes_in_group("player"):
		if node.visible:
			stored = node

var Groupnum = 0

func parse(data:Array):
	for array in data:
		for line in array:
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
	$"CanvasLayer3/Proporties Panel".add_function_preset()



func _on_view_index_pressed(index):
	#0 Hide UI
	#1 Loop Movements
	#2 Whole Level View
	#3 reset cam pos
	if not disabledcontrolls:
		match index:
			0:
				if $Cam.paused == false and propertypanel == false:
					$Cam.toggleUI()
			1:
				movingLoop = not movingLoop
			2:
				$Cam.toggleCam()
			3:
				$Cam.position = Vector2(-216,-397)


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

func _on_debug_index_pressed(index):
	match index:
		0:
			set_points_data("Rail")
			set_points_data("Moving")
			set_points_data("Spin")
		1:
			
			#endplat[19][19] #gets the character after param in param1
			for node in get_tree().get_nodes_in_group("Moving"):
				if node is MovingRail:
					#print("test:",node.endplat[19]) #prints param0
					if node.endplat[20][19] == node.endplat[21][19]:
						node.endplat[20][19] = str(int(node.endplat[21][19])-1)
						push_warning("FIXED DUPLICATE KEY!!")
		2:
			var IDs = []
			var rails = []
			IDs += filter_id("Rail")[0]
			IDs += filter_id("Moving")[0]
			IDs += filter_id("Spin")[0]
			rails += filter_id("Rail")[1]
			rails += filter_id("Moving")[1]
			rails += filter_id("Spin")[1]
			for entry in IDs:
				var startingIndex = IDs.find(entry)+1
				print(IDs.find(entry,startingIndex))
				if IDs.find(entry,startingIndex) != -1:
					print("DUPLICATE AT ",IDs.find(entry,startingIndex))
					var troubleRail = rails[IDs.find(entry,startingIndex)]
					if troubleRail is PathRail:
						troubleRail.color = Color.GREEN
					else:
						troubleRail.rail.texture = preload("res://Sprites/Rails/trouble.png")
					troubleRail = rails[startingIndex-1]
					if troubleRail is PathRail:
						troubleRail.color = Color.ORANGE
					else:
						troubleRail.rail.texture = preload("res://Sprites/Rails/trouble2.png")

func set_points_data(group_name):
	for node in get_tree().get_nodes_in_group(group_name):
		for point in node.points:
			point.set_data()

func filter_id(group_name):
	var IDs = []
	var Rails = []
	for node in get_tree().get_nodes_in_group(group_name):
		IDs.append(node.idnum)
		Rails.append(node)
	return [IDs,Rails]

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

func _on_grid_text_changed(new_text):
	if float(new_text) > 0:
		grid = float(new_text)
	if grid >= 10 and $nonmoving/gridenabled.button_pressed: #dont show small grid
		$stage/Grid.position = Vector2(grid*-202,grid*-42)
		$stage/Grid.cell_size = Vector2(grid,grid)
		$stage/Grid.show()
	else:
		$stage/Grid.hide()


func _on_gridenabled_pressed():
	_on_grid_text_changed($nonmoving/grid.text)
