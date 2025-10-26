extends Button

@onready var fileDialog = get_parent().get_node("FileDialog")
var content
var loaded = false
var rail = false

var playerposition = Vector2(-216,-397)
var highestID = 0

var railIDlist = {
	"Normal":[],
	"Blue":["1200"],
	"Invisible":["0.00"],
	"Music":["5100","6000"],
	"RMove":["2141"],
	"LMove":["2140"],
	"RCrankMove":["2111"],
	"LCrankMove":["2110"],
	"AutoMove":["2000","2200","2300","4300"],
	"EndMove":["2380","2381","2382","2383","2384","2385","2386","2387","2388","2389","2390","2391","2392","2393","2394"],
	"FanMove":["2150"],
	"PathRail":["2900","4900"],
	"RRotate":["3141"],
	"LRotate":["3140","3150"],
	"AutoRotate":["3200","3300","3322","3423"],
	"RSPivot":["3113"],
	"LSPivot":["3112"],
	"RSpin":["3011","3111"],
	"LSpin":["3010","3110"],
	"EndRotate":["3380","3381","3382","3383","3384","3385","3386","3387","3388","3389","3390","3391","3392","3393"],
	}

func _on_load_pressed():
	fileDialog.current_path = Options.filepath
	if Options.OSFileManager == "true":
		fileDialog.use_native_dialog = true
	fileDialog.popup_centered(Vector2(1600,800))


func _process(_delta):
	if loaded == false:
		if Input.is_action_just_pressed("Paste"):
			content = DisplayServer.clipboard_get()
			fileDialog.current_path = Options.filepath
			$AnimationPlayer.play("transition")
			LoadTest("untitled")


var currentLayer:int = -1
var currentMode:String = "object"
var movingPlatforms:Dictionary = {}

var scene = preload("res://Creator.tscn").instantiate()
func LoadTest(filename):
	$CanvasLayer.show()
	self_modulate = Color(1,1,1,0)
	$AnimationPlayer.play("transition")
	content = str(content).split("\n") #splits it into lines
	$CanvasLayer/LoadingBar.max_value = content.size()
	loaded = true
	for node in get_tree().get_nodes_in_group("hide"):
		node.hide() # hides everything that needs to be gone
	scene.filepath = fileDialog.current_dir + "/"
	get_parent().add_child(scene)
	scene.get_node("Cam").enabled = true
	scene.get_node("nonmoving/name").text = filename
	get_parent().scale = Vector2(1,1)
	
	while content.size() > 0:
		$CanvasLayer/LoadingBar.value = $CanvasLayer/LoadingBar.max_value - content.size()
		if randi_range(1,20) == 1:
			await get_tree().create_timer(.0001).timeout # lets the loading bar update by pausing the loading
		var matched = false
		match content[0]:
			"    - Infos:":
				currentLayer += 1
				print("CurrentLayer:",currentLayer)
				currentMode = "object"
				content.remove_at(0)
				matched = true
			"        RailInfos:":
				currentMode = "rail"
				content.remove_at(0)
				matched = true
			"          - comment: !l -1":
				var amount = 27
				var objectdata = []
				while amount > 0:
					objectdata.append(content[0])
					content.remove_at(0)
					amount -= 1
				matched = true
				var instance = getObject(objectdata[8])
				if instance != null:
					scene.add_child(instance)
					instance.data = objectdata
					instance.reposition()
					scene.connect("EXPORT", Callable(instance, "EXPORT"))
					if objectdata[8] == "            name: Dkb_Player":
						playerposition = instance.position
						scene.get_node("Player").play("out")
			"            - Points:":
				var raildata:PackedStringArray = []
				
				var amount = content.find("              closed: CLOSE")
				
				
				while amount > 0:
					raildata.append(content[0])
					content.remove_at(0)
					amount -= 1
				var railend:PackedStringArray = []
				amount = content.find("              unit_name: Path")+1
				while amount > 0:
					railend.append(content[0])
					content.remove_at(0)
					amount -= 1
				matched = true
				
				var instance = getRail(railend[8])
				var id = railend[2].erase(0,27)
				if int(id) > highestID:
					highestID = int(id)
				if railend[8].begins_with("              param0: 2900") or railend[8].begins_with("              param0: 4900"):
					
					movingPlatforms[id] = instance
				if railend[18].begins_with("              param0: 2") or railend[19].begins_with("              param0: 2") or railend[19].begins_with("              param0: 4300") or railend[18].begins_with("              param0: 4300"):#moving platform
					
					for railline in railend:
						if railline.contains("linkID:"):
							id = railline.erase(0,30)
							if int(id) > highestID:
								highestID = int(id)
						if railline.begins_with("              param0:"):
							instance = getRail(railline)
					var oldrail = movingPlatforms.get(id)
					if oldrail == null:
						print("Repositioned:",id)
						content += raildata
						content += railend
					else:
						oldrail.railscene = instance
						instance = oldrail
						instance.pathdone(Vector2(int(raildata[raildata.find("                  dir_z: 0.00000")+8].lstrip("                  pnt0_x: ")),-int(raildata[raildata.find("                  dir_z: 0.00000")+9].lstrip("                  pnt0_y: "))))
						instance = instance.childrail
						AddPoints(raildata,instance,"")
						instance.done()
						instance.data = raildata
						instance.endplat = railend
						oldrail.reposition()
						movingPlatforms.erase(id)
					
				else:
					var prereference = ""
					instance.loading = true
					scene.add_child(instance)
					if railend[8].begins_with("              param0: 3"):
						prereference = "Spin/"# add this to get node calls if it's a rotate rail
					instance.get_node(prereference+"start").position = Vector2(int(raildata[raildata.find("                  dir_z: 0.00000")+8].lstrip("                  pnt0_x: ")),-int(raildata[raildata.find("                  dir_z: 0.00000")+9].lstrip("                  pnt0_y: ")))
					AddPoints(raildata,instance,prereference)
					if prereference == "":
						instance.data = raildata
						instance.end = railend
					else:
						instance.get_node(prereference).data = raildata
						instance.get_node(prereference).end = railend
						
					
					if railend[8].begins_with("              param0: 2900") or railend[8].begins_with("              param0: 4900"):
						movingPlatforms[id] = instance
					else:#if it isn't a moving rail
						instance.done()
						instance.reposition()
					
					scene.connect("EXPORT", Callable(instance, "EXPORT"))
		if matched == false:
			content.remove_at(0)
	$CanvasLayer.hide()
	
	scene.get_node("Cam").paused = false
	scene.disabledcontrolls = false
	scene.get_node("Cam").position = playerposition
	scene.get_node("Cam").zoom = Vector2(2.5,2.5)
	scene.get_node("Cam").toggleUI()
	for flag in get_tree().get_nodes_in_group("checkpoint"): #adds the checkpoints to the array
		scene.checkpoints.append(int(flag.data[13].erase(0,20)))
	scene.idnum = highestID + 1
	print("HighestID:",highestID)
	if movingPlatforms.size() != 0:
		push_error("Not All Platforms Have a Pair!")

func AddPoints(raildata,instance,prereference):
	var pointpos = Vector2.ZERO
	var first = true
	for railline in raildata:
		if railline.begins_with("                  pnt0_x:"):
			pointpos.x = float(railline.erase(0,26))
		if railline.begins_with("                  pnt0_y:"):
			if first == false:
				pointpos.y = -float(railline.erase(0,26))
				instance.get_node(prereference+"end").position = pointpos
				instance.newseg()
			else:
				first = false

func MovingRail(Railname) -> PackedScene:
	var Railscene = preload("res://FanMove.tscn") # default is fan
	
	if Railname in railIDlist.RMove:
		Railscene = preload("res://RMove.tscn")
	if Railname in railIDlist.LMove:
		Railscene = preload("res://LMove.tscn")
	if Railname in railIDlist.AutoMove:
		Railscene = preload("res://AutoMove.tscn")
	if Railname in railIDlist.RCrankMove:
		Railscene = preload("res://Rcrank.tscn")
	if Railname in railIDlist.LCrankMove:
		Railscene = preload("res://Lcrank.tscn")
	if Railname in railIDlist.FanMove: #redundant but whatevers
		Railscene = preload("res://FanMove.tscn")
	if Railname in railIDlist.EndMove:
		Railscene = preload("res://EndMove.tscn")
	return Railscene

func getRail(Railname:String):
	var Railscene = preload("res://DefaultRail.tscn").instantiate()
	var RailID = Railname.erase(26,6).erase(0,22) #the railID with nothing else
	if Railname.begins_with("              param0: 2") or Railname.begins_with("              param0: 4300") or Railname.begins_with("              param0: 4900.00000"):
		if RailID in railIDlist.PathRail:
			Railscene = preload("res://PathRail.tscn").instantiate()
			
		else:
			
			return MovingRail(RailID)
	#if not a moving rail
	print(Railname)
	print("RotatingRail:",RailID)
	
	if RailID in railIDlist.Invisible:
		Railscene = preload("res://InvisibleRail.tscn").instantiate()
	if RailID in railIDlist.Blue:
		Railscene = preload("res://BlueRail.tscn").instantiate()
	if RailID[0] == "3": #if rotating rail
		Railscene = preload("res://Rspin.tscn").instantiate()
	if RailID in railIDlist.Music:
		Railscene = preload("res://musicrail.tscn").instantiate()
	if RailID in railIDlist.RSpin:
		Railscene = preload("res://Rspin.tscn").instantiate()
	if RailID in railIDlist.LSpin:
		Railscene = preload("res://Lspin.tscn").instantiate()
	if RailID in railIDlist.LRotate:
		Railscene = preload("res://LRotate.tscn").instantiate()
	if RailID in railIDlist.RRotate:
		Railscene = preload("res://RRotate.tscn").instantiate()
	if RailID in railIDlist.AutoRotate:
		Railscene = preload("res://AutoRotate.tscn").instantiate()
	if RailID in railIDlist.EndRotate:
		Railscene = preload("res://EndRotate.tscn").instantiate()
	if RailID in railIDlist.RSPivot:
		Railscene = preload("res://RSpivit.tscn").instantiate()
	if RailID in railIDlist.LSPivot:
		Railscene = preload("res://LSpivit.tscn").instantiate()
	return Railscene

func getObject(Objectname:String) -> Node:
	var Objectscene = preload("res://banana.tscn").instantiate()
	match Objectname:
		"            name: Dkb_BlackBoard01":
			return
		"            name: Dkb_Player":
			var player = preload("res://player.tscn").instantiate()
			Objectscene = player
			scene.stored = player
		"            name: Dkb_CheckPoint":
			if Objectname.begins_with("            param0: 2.00000"):
				Objectscene = preload("res://finalcheckpoint.tscn").instantiate()
			else:
				Objectscene = preload("res://checkpoint.tscn").instantiate()
				if Objectname.begins_with("            param0: 1"):
					Objectscene = preload("res://firstcheckpoint.tscn").instantiate()
			if content[24] == "            scale_x: -1.00000":
				Objectscene.flip_h = true
		"            name: Dkb_Banana":
			Objectscene = preload("res://banana.tscn").instantiate()
		"            name: Dkb_ChalkEntrance":
			Objectscene = preload("res://door.tscn").instantiate()
		"            name: Dkb_ChalkRainbow":
			Objectscene = preload("res://door.tscn").instantiate()
			Objectscene.texture = preload("res://rainbow.png")
			Objectscene.offset.y = 0
		"            name: Dkb_OneUpItem":
			Objectscene = preload("res://1up.tscn").instantiate()
		"            name: Dkb_Coin":
			Objectscene = preload("res://coin.tscn").instantiate()
		"            name: Dkb_ChalkDonkey":
			Objectscene = preload("res://dk.tscn").instantiate()
		"            name: Dkb_ChalkPauline":
			Objectscene = preload("res://pauline.tscn").instantiate()
		"            name: Dkb_ChalkBag":
			Objectscene = preload("res://purse.tscn").instantiate()
		"            name: Dkb_ChalkUmbrella":
			Objectscene = preload("res://hammer.tscn").instantiate()
		"            name: Dkb_ChalkLadder":
			Objectscene = preload("res://ladder.tscn").instantiate()
			Objectscene.get_node("pitch").loading = true
			
		"            name: Dkb_ChalkBarrel":
			Objectscene = preload("res://barrel.tscn").instantiate()
	#Decide the type of arrow
	if Objectname.begins_with("            name: Dkb_ChalkYajirushi"):
		Objectscene = preload("res://Arrow.tscn").instantiate()
		Objectscene.ObjectName = Objectname.erase(0,18)
	return Objectscene

func _on_FileDialog_file_selected(path):
	var file = FileAccess.open(path, FileAccess.READ)
	
	
	var filename = str(path).get_file().left(str(path).get_file().length() - 1)
	filename = filename.erase(filename.length() - 3,3)
	content = file.get_as_text()
	
	file.close()
	LoadTest(filename)
