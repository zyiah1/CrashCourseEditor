extends Button

@onready var fileDialog = get_parent().get_node("FileDialog")
var content
var loaded = false
var rail = false

var playerposition = Vector2(-216,-397)

func _on_load_pressed():
	fileDialog.current_path = Options.filepath
	fileDialog.popup_centered(Vector2(1600,800))

func _process(delta):
	if loaded == false:
		if Input.is_action_just_pressed("Paste"):
			content = DisplayServer.clipboard_get()
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
	var timer = Timer.new()
	add_child(timer)
	timer.start(.05)
	await timer.timeout;
	content = str(content)
	content = content.split("\n")
	$CanvasLayer/LoadingBar.max_value = content.size()
	var cycle = 8
	loaded = true
	
	for node in get_tree().get_nodes_in_group("hide"):
		node.hide()
	get_parent().add_child(scene)
	scene.get_node("Cam").enabled = true
	scene.get_node("nonmoving/name").text = filename
	get_parent().scale = Vector2(1,1)
	
	var railtype = "normal"
	var nextid = 0
	var overide = 0
	var objinterested = false
	var railinterested = false
	var trackedinfo = []
	var ignore = 4
	var actualrail = null
	while content.size() > 0:
		$CanvasLayer/LoadingBar.value = $CanvasLayer/LoadingBar.max_value - content.size()
		if randi_range(1,20) == 1:
			await get_tree().create_timer(.0001).timeout
		var matched = false
		match content[0]:
			"    - Infos:":
				currentLayer += 1
				print(currentLayer)
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
					scene.nodes.append(instance)
					scene.add_child(instance)
					instance.data = objectdata
					instance.reposition()
					scene.connect("EXPORT", Callable(instance, "EXPORT"))
					if objectdata[8] == "            name: Dkb_Player":
						playerposition = instance.position
						scene.get_node("CanvasLayer3/CanvasLayer/buttons").play("out")
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
				if railend[18].begins_with("              param0: 2") or railend[19].begins_with("              param0: 2") or railend[19].begins_with("              param0: 4300") or railend[18].begins_with("              param0: 4300"):#moving platform
					
					var Id
					for railline in railend:
						if railline.contains("linkID:"):
							Id = railline.erase(0,30)
						if railline.begins_with("              param0:"):
							instance = getRail(railline)
					var oldrail = movingPlatforms.get(Id)
					if oldrail == null:
						print("Repositioned:",Id)
						content += raildata
						content += railend
					else:
						oldrail.rail = instance
						instance = oldrail
						instance.done(Vector2(int(raildata[raildata.find("                  dir_z: 0.00000")+8].lstrip("                  pnt0_x: ")),-int(raildata[raildata.find("                  dir_z: 0.00000")+9].lstrip("                  pnt0_y: "))))
						instance = instance.childrail
						AddPoints(raildata,instance,"")
						instance.done()
						instance.data = raildata
						instance.endplat = railend
						oldrail.reposition()
						movingPlatforms.erase(Id)
					
				else:
					var prereference = ""
					instance.loading = true
					scene.add_child(instance)
					if railend[8].begins_with("              param0: 3"):
						prereference = "Spin/"# add this to get node calls if it's a rotate rail
					instance.get_node(prereference+"start").position = Vector2(int(raildata[raildata.find("                  dir_z: 0.00000")+8].lstrip("                  pnt0_x: ")),-int(raildata[raildata.find("                  dir_z: 0.00000")+9].lstrip("                  pnt0_y: ")))
					AddPoints(raildata,instance,prereference)
					scene.nodes.append(instance)
					if prereference == "":
						instance.data = raildata
						instance.end = railend
					else:
						instance.get_node(prereference).data = raildata
						instance.get_node(prereference).end = railend
						
					
					if railend[8].begins_with("              param0: 2900") or railend[8].begins_with("              param0: 4900"):
						var id = railend[2].erase(0,27)
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
	var Railscene = preload("res://fanrail.tscn") # default is fan
	match Railname:
		"              param0: 2141.00000":
			Railscene = preload("res://Rrail.tscn")
		"              param0: 2392.00000":
			Railscene = preload("res://Endmoverail.tscn")
		"              param0: 2200.00000":
			Railscene = preload("res://Autorail.tscn")
		"              param0: 2300.00000":
			Railscene = preload("res://Autorail.tscn")
		"              param0: 2000.00000":
			Railscene = preload("res://Autorail.tscn")
		"              param0: 4300.00000":
			Railscene = preload("res://Autorail.tscn")
		"              param0: 2110.00000":
			Railscene = preload("res://Lcrank.tscn")
		"              param0: 2111.00000":
			Railscene = preload("res://Rcrank.tscn")
		"              param0: 2150.00000":
			Railscene = preload("res://fanrail.tscn")
		"              param0: 2140.00000":
			Railscene = preload("res://Lrail.tscn")
	return Railscene
func getRail(Railname:String):
	var Railscene = preload("res://bridge.tscn").instantiate()
	if Railname.begins_with("              param0: 2") or Railname.begins_with("              param0: 4300") or Railname.begins_with("              param0: 4900.00000"):
		if Railname == "              param0: 2900.00000" or Railname.begins_with("              param0: 4900.00000"):
			Railscene = preload("res://R.tscn").instantiate()
			
		else:
			
			return MovingRail(Railname)
	
	match Railname:
		"              param0: 0.00000":
			Railscene.invisible = true
		"              param0: 1200.00000":
			
			Railscene.color = Color(.13,.58,.87,1)
		"              param0: 5100.00000":
			Railscene = preload("res://musicrail.tscn").instantiate()
		"              param0: 6000.00000" :
			Railscene = preload("res://musicrail.tscn").instantiate()
		"              param0: 3110.00000":
			Railscene = preload("res://Lspin.tscn").instantiate()
		"              param0: 3010.00000":
			Railscene = preload("res://Lspin.tscn").instantiate()
		"              param0: 3111.00000":
			Railscene = preload("res://Rspin.tscn").instantiate()
		"              param0: 3011.00000":
			Railscene = preload("res://Rspin.tscn").instantiate()
		"              param0: 3140.00000":
			Railscene = preload("res://Lpivot.tscn").instantiate()
		"              param0: 3150.00000":
			Railscene = preload("res://Lpivot.tscn").instantiate()
		"              param0: 3300.00000":
			Railscene = preload("res://Apivot.tscn").instantiate()
		"              param0: 3200.00000":
			Railscene = preload("res://Apivot.tscn").instantiate()
		"              param0: 3423.00000":
			Railscene = preload("res://Apivot.tscn").instantiate()
		"              param0: 3322.00000":
			Railscene = preload("res://Apivot.tscn").instantiate()
		"              param0: 3392.00000":
			Railscene = preload("res://Endpivot.tscn").instantiate()
		"              param0: 3141.00000":
			Railscene = preload("res://Rpivot.tscn").instantiate()
		"              param0: 3112.00000":
			Railscene = preload("res://LSpivit.tscn").instantiate()
		"              param0: 3113.00000":
			Railscene = preload("res://RSpivit.tscn").instantiate()
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
					Objectscene.changetofirst()
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
		"            name: Dkb_ChalkYajirushi_Kaiten":
			Objectscene = preload("res://Arrow.tscn").instantiate()
			Objectscene.type = "rotate"
		"            name: Dkb_ChalkYajirushi_Arrow":
			Objectscene = preload("res://Arrow.tscn").instantiate()
			Objectscene.type = "big"
		"            name: Dkb_ChalkYajirushi_45":
			Objectscene = preload("res://Arrow.tscn").instantiate()
			Objectscene.type = "45"
		"            name: Dkb_ChalkYajirushi_90":
			Objectscene = preload("res://Arrow.tscn").instantiate()
			Objectscene.type = "90"
		"            name: Dkb_ChalkYajirushi_180":
			Objectscene = preload("res://Arrow.tscn").instantiate()
			Objectscene.type = "180"
		"            name: Dkb_ChalkYajirushi_00":
			Objectscene = preload("res://Arrow.tscn").instantiate()
		"            name: Dkb_ChalkUmbrella":
			Objectscene = preload("res://hammer.tscn").instantiate()
		"            name: Dkb_ChalkLadder":
			Objectscene = preload("res://ladder.tscn").instantiate()
			Objectscene.loading = true
			
		"            name: Dkb_ChalkBarrel":
			Objectscene = preload("res://barrel.tscn").instantiate()
	return Objectscene

func _on_FileDialog_file_selected(path):
	var file = FileAccess.open(path, FileAccess.READ)
	
	
	var filename = str(path).get_file().left(str(path).get_file().length() - 1)
	filename = filename.erase(filename.length() - 3,3)
	content = file.get_as_text()
	
	file.close()
	LoadTest(filename)

