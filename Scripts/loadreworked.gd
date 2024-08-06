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
				if railend[18].begins_with("              param0: 2") or railend[19].begins_with("              param0: 2"):#moving platform
					if railend[19].begins_with("              param0: 2"):
						instance = getRail(railend[19])
					else:
						instance = getRail(railend[18])
					
					var Id
					for railline in railend:
						if railline.contains("linkID:"):
							Id = railline.erase(0,30)
					var oldrail = movingPlatforms.get(Id)
					if oldrail == null:
						print(Id)
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
						
					
					if railend[8].begins_with("              param0: 2900"):
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
			Railscene = preload("res://EndMoverail.tscn")
		"              param0: 2200.00000":
			Railscene = preload("res://Autorail.tscn")
		"              param0: 2300.00000":
			Railscene = preload("res://Autorail.tscn")
		"              param0: 2000.00000":
			Railscene = preload("res://Autorail.tscn")
		"              param0: 4300.00000":
			Railscene = preload("res://Autorail.tscn")
		"              param0: 2110.00000":
			Railscene = preload("res://lcrank.tscn")
		"              param0: 2111.00000":
			Railscene = preload("res://RCrank.tscn")
		"              param0: 2150.00000":
			Railscene = preload("res://fanrail.tscn")
		"              param0: 2140.00000":
			Railscene = preload("res://Lrail.tscn")
	return Railscene
func getRail(Railname:String):
	var Railscene = preload("res://bridge.tscn").instantiate()
	if Railname.begins_with("              param0: 2"):
		if Railname == "              param0: 2900.00000" or Railname == "              param0: 4900.00000":
			var nextid = -1
			var cycle = -1
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

func Load(filename):
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
	var scene = preload("res://Creator.tscn").instantiate()
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
	var instance = null
	var ignore = 4
	var actualrail = null
	
	var everypivotrail = [] #idk shuffle through all of them and call a function
	var playerposition = Vector2(-216,-397)
	
	while content.size()>0:
		$CanvasLayer/LoadingBar.value += 1
		overide = 0
		cycle -= 1
		
		#check wether to switch to rails
		if content[0] == "            - Points:":
			if ignore == 0:
				railinterested = true
			else:
				ignore -= 1
		
		if railinterested == true:
			
			#BS WORKAROUNDS (delete duplicated things)
			trackedinfo.append(content[0])
			if trackedinfo[trackedinfo.size()-1].begins_with("                - dir_x:"):
				if trackedinfo[trackedinfo.size()-2].begins_with("                - dir_x:"):
					trackedinfo.remove_at(trackedinfo.size()-1)
			if trackedinfo[trackedinfo.size()-1].begins_with("                - comment: !l -1"):
				if trackedinfo[trackedinfo.size()-2].begins_with("                - comment: !l -1"):
					trackedinfo.remove_at(trackedinfo.size()-1)
			#end of that 
			
			
		if content[0].begins_with("              closed:"):
			#this keeps the data that has all the points
			if railinterested == true:
				var keepthis = trackedinfo[trackedinfo.size()-1]
				trackedinfo.remove_at(trackedinfo.size()-1)
				actualrail = rail
				if railtype == "turn":
					actualrail = rail.get_node("Spin")
					everypivotrail.append(actualrail)
				
				if railtype == "fanchild":
					actualrail = actualrail.get_parent()
				
				actualrail.data = trackedinfo
				if trackedinfo[1] == "            - Points:":
					
					
					actualrail.data.remove_at(1)
				trackedinfo = []
				trackedinfo.append(keepthis)
		if content[0].begins_with("              unit_name: "):
			#this keeps the end of the data intact after all the points
			if railinterested == true:
				print(railtype)
				if railtype == "fanchild":
					#need to get parent due to actualrail already being the child
					actualrail.end = trackedinfo
				else:
					if railtype == "none":
						#for child
						actualrail.endplat = trackedinfo
					else:
						#for the rail
						actualrail.end = trackedinfo
						
				
				trackedinfo = []
				railinterested = false
		
		if content[0] == "          - comment: !l -1":
			if content[8] != "            name: Dkb_BlackBoard01":
				objinterested = true
		if objinterested == true:
			trackedinfo.append(content[0])
		if content[0].begins_with("            scale_z: "):
			if objinterested == true:
				objinterested = false
				if instance != null:
					if trackedinfo[1] == "          - comment: !l -1":
						trackedinfo.remove_at(0)
					instance.data = trackedinfo
					trackedinfo = []
		
		
		if cycle + 1 > 0:#remove whatever amount the cycle is 
			content.remove_at(0)
			if randi_range(1,500) == 1:
				await get_tree().create_timer(.0001).timeout
		else:
			
			if content[0] != "          - comment: !l -1": # if it's a rail
				if content[0] == "            - Points:":
					var firstoffset = 0
					if content[1].begins_with("                - dir_x:"):
						cycle = 24
						firstoffset = 1
					else:
						cycle = 25
					if railtype != "fanchild":
						
						var id = 0
						var pre = 0
						for line2 in content:
							pre += 1
							if line2 == "              closed: CLOSE":
								if id == 0:
									id = pre +7
									if content[id].begins_with("              param1:"):
										id-=1
										pre-=1
									if content[id] != "              param0: 2900.00000" and content[id] !=  "              param0: 4900.00000":
										break #if it's not gonna be a moving rail stop
							if id != 0:
								#print("pathrail detexted")
								rail = preload("res://fan.tscn").instantiate()
								railtype = "fan"
								#get the next id so we can actually index it
								if line2.begins_with("                  type: Rail_Rail"):
									nextid = pre + 4
									#print(content[nextid])
									railtype = "fan"
									if str(content[nextid]).begins_with("              param1:"):
										nextid -= 1
										push_warning("had to correct a moving platform")
									break
						
						if nextid < content.size():
							
							match content[nextid]:
								"              param0: 2141.00000":
									rail = preload("res://R.tscn").instantiate()
								"              param0: 2392.00000":
									rail = preload("res://EndMove.tscn").instantiate()
								"              param0: 2200.00000":
									rail = preload("res://Auto.tscn").instantiate()
								"              param0: 2300.00000":
									rail = preload("res://Auto.tscn").instantiate()
								"              param0: 2000.00000":
									rail = preload("res://Auto.tscn").instantiate()
								"              param0: 4300.00000":
									rail = preload("res://Auto.tscn").instantiate()
								"              param0: 2110.00000":
									rail = preload("res://lcrankrail.tscn").instantiate()
								"              param0: 2111.00000":
									rail = preload("res://RCrankRail.tscn").instantiate()
								"              param0: 2150.00000":
									rail = preload("res://fan.tscn").instantiate()
								"              param0: 2140.00000":
									rail = preload("res://L.tscn").instantiate()
							#print(content[nextid])
							
						if content[id] == "              param0: 1000.00000" or content[id] == "              param0: 1100.00000"  or content[id] == "              param0: 5013.00000" or content[id] == "              param0: 5060.00000" or content[id] == "              param0: 5040.00000" or content[id] == "              param0: 5041.00000" or content[id] == "              param0: 5260.00000" or content[id] == "              param0: 5211.00000" or content[id] == "              param0: 5240.00000" or content[id] == "              param0: 5241.00000" or content[id] == "              param0: 3090.00000"or content[id] == "              param0: 3040.00000" or content[id] == "              param0: 2423.00000"or content[id] == "              param0: 3160.00000"or content[id] == "              param0: 3080.00000"or content[id] == "              param0: 2423.00000" or content[id] == "              param0: 5250.00000" or content[id] == "              param0: 5020.00000":
							rail = preload("res://bridge.tscn").instantiate()
							railtype = "normal"
						match content[id]:
							"              param0: 0.00000":
								rail = preload("res://bridge.tscn").instantiate()
								rail.invisible = true
								railtype = "normal"
							"              param0: 1200.00000":
								rail = preload("res://bridge.tscn").instantiate()
								railtype = "normal"
								rail.color = Color(.13,.58,.87,1)
							"              param0: 5100.00000":
								rail = preload("res://musicrail.tscn").instantiate()
								railtype = "normal"
							"              param0: 6000.00000" :
								rail = preload("res://musicrail.tscn").instantiate()
								railtype = "normal"
							"              param0: 3110.00000":
								rail = preload("res://Lspin.tscn").instantiate()
							"              param0: 3010.00000":
								rail = preload("res://Lspin.tscn").instantiate()
							"              param0: 3111.00000":
								rail = preload("res://Rspin.tscn").instantiate()
							"              param0: 3011.00000":
								rail = preload("res://Rspin.tscn").instantiate()
							"              param0: 3140.00000":
								rail = preload("res://Lpivot.tscn").instantiate()
							"              param0: 3150.00000":
								rail = preload("res://Lpivot.tscn").instantiate()
								push_error("Figure this one out please")
							"              param0: 3300.00000":
								rail = preload("res://Apivot.tscn").instantiate()
							"              param0: 3200.00000":
								rail = preload("res://Apivot.tscn").instantiate()
							"              param0: 3423.00000":
								rail = preload("res://Apivot.tscn").instantiate()
							"              param0: 3322.00000":
								rail = preload("res://Apivot.tscn").instantiate()
							"              param0: 3392.00000":
								rail = preload("res://Endpivot.tscn").instantiate()
							"              param0: 3141.00000":
								rail = preload("res://Rpivot.tscn").instantiate()
							"              param0: 3112.00000":
								rail = preload("res://LSpivit.tscn").instantiate()
							"              param0: 3113.00000":
								rail = preload("res://RSpivit.tscn").instantiate()
						if rail.get_node_or_null("Spin") != null:
							
							railtype = "turn"
							rail.get_node("Spin").loading = true
							if not content[id + 1].begins_with("              param1: 1"):
								rail.get_node("Spin/rotation").text = str(-int(str(content[id + 1]).lstrip("              param1: ")))
							else:
								rail.get_node("Spin/rotation").text = "-1"+str(int(str(content[id + 1]).lstrip("              param1: ")))
							rail.get_node("Spin/rotation").prev = rail.get_node("Spin/rotation").text
							rail.get_node("Spin/start").position = Vector2(int(content[12-firstoffset].lstrip("                  pnt0_x: ")),-int(content[13-firstoffset].lstrip("                  pnt0_y: ")))
					rail.loading = true
					if railtype != "turn":
						var startpos = Vector2(int(content[12-firstoffset].lstrip("                  pnt0_x: ")),-int(content[13-firstoffset].lstrip("                  pnt0_y: ")))
						rail.get_node("start").position = startpos
						
						if railtype == "fanchild":
							rail.rail.add_point(startpos)
							rail.get_node("preview").rail.add_point(startpos)
						
					if railtype != "fanchild":
						if not rail.is_inside_tree():  #has not been added
							scene.connect("EXPORT", Callable(rail, "EXPORT"))
							scene.add_child(rail)
							scene.nodes.append(rail)
				var offset = 0
				
				if content[0] == "                - dir_x: 0.00000" and overide != 1:
					offset = 1
				if content[0].begins_with("                - ") and overide != 1:
					if rail.get_node_or_null("end") == null:
						rail.get_node("Spin/end").position = Vector2(int(content[11-offset].lstrip("                  pnt0_x: ")),-int(content[12-offset].lstrip("                  pnt0_y: ")))
					else:
						rail.get_node("end").position = Vector2(int(content[11-offset].lstrip("                  pnt0_x: ")),-int(content[12-offset].lstrip("                  pnt0_y: ")))
					if content[24-offset] == "              closed: CLOSE": #if no more segments
						cycle = 44-offset
						rail.newseg()
						if railtype == "fan":
							
							
							
							if str(content[56-offset]).begins_with("                  pnt0_y:"):
								rail.done(Vector2(int(content[56-offset].lstrip("                  pnt0_x: ")),-int(content[57-offset].lstrip("                  pnt0_y: "))))
							else:
								rail.done(Vector2(int(content[57-offset].lstrip("                  pnt0_x: ")),-int(content[58-offset].lstrip("                  pnt0_y: "))))
								rail.loading = true
							
							
						else:
							rail.done()
						
						if railtype == "fanchild":
							#print(content)
							railtype = "none"
							cycle = 54-offset
						
						if railtype == "fan": #has to go after the fanchild one
							rail = rail.childrail
							railtype = "fanchild"
							overide = 1
						
					else:# if there are more segments left inside of the rail
						cycle = 24-offset
						rail.newseg()
					
				
			else: 
				#objects importer
				
				
				
				cycle = 27
				match content[8]:
					"            name: Dkb_Player":
						var player = preload("res://player.tscn").instantiate()
						player.position = Vector2(int(content[21].lstrip("            pos_x: ")),-int(content[22].lstrip("            pos_y: ")))
						instance = player
						playerposition = player.position
						scene.get_node("CanvasLayer3/CanvasLayer/buttons").play("out")
						scene.stored = player
					"            name: Dkb_CheckPoint":
						if content[8].begins_with("            param0: 2.00000"):
							instance = preload("res://finalcheckpoint.tscn").instantiate()
						else:
							instance = preload("res://checkpoint.tscn").instantiate()
							if content[8].begins_with("            param0: 1"):
								instance.changetofirst()
						if content[24] == "            scale_x: -1.00000":
							instance.flip_h = true
					"            name: Dkb_Banana":
						instance = preload("res://banana.tscn").instantiate()
					"            name: Dkb_ChalkEntrance":
						instance = preload("res://door.tscn").instantiate()
					"            name: Dkb_ChalkRainbow":
						instance = preload("res://door.tscn").instantiate()
						instance.texture = preload("res://rainbow.png")
						instance.offset.y = 0
					"            name: Dkb_OneUpItem":
						instance = preload("res://1up.tscn").instantiate()
					"            name: Dkb_Coin":
						instance = preload("res://coin.tscn").instantiate()
					"            name: Dkb_ChalkDonkey":
						instance = preload("res://dk.tscn").instantiate()
					"            name: Dkb_ChalkPauline":
						instance = preload("res://pauline.tscn").instantiate()
					"            name: Dkb_ChalkBag":
						instance = preload("res://purse.tscn").instantiate()
					"            name: Dkb_ChalkYajirushi_Kaiten":
						instance = preload("res://Arrow.tscn").instantiate()
						instance.type = "rotate"
					"            name: Dkb_ChalkYajirushi_Arrow":
						instance = preload("res://Arrow.tscn").instantiate()
						instance.type = "big"
					"            name: Dkb_ChalkYajirushi_45":
						instance = preload("res://Arrow.tscn").instantiate()
						instance.type = "45"
					"            name: Dkb_ChalkYajirushi_90":
						instance = preload("res://Arrow.tscn").instantiate()
						instance.type = "90"
					"            name: Dkb_ChalkYajirushi_180":
						instance = preload("res://Arrow.tscn").instantiate()
						instance.type = "180"
					"            name: Dkb_ChalkYajirushi_00":
						instance = preload("res://Arrow.tscn").instantiate()
					"            name: Dkb_ChalkUmbrella":
						instance = preload("res://hammer.tscn").instantiate()
					"            name: Dkb_ChalkLadder":
						instance = preload("res://ladder.tscn").instantiate()
						instance.loading = true
						
						match int(content[8].lstrip("            param0: ")):
							1:
								instance.texture = preload("res://ladder1.png")
							2:
								instance.texture = preload("res://ladder2.png")
							#3 is the default
							4:
								instance.texture = preload("res://ladder4.png")
							5:
								instance.texture = preload("res://ladder5.png")
							6:
								instance.texture = preload("res://ladder6.png")
					"            name: Dkb_ChalkBarrel":
						instance = preload("res://barrel.tscn").instantiate()
				
				if instance != null:
					if not instance in scene.nodes:
						instance.position = Vector2(float(content[21].lstrip("            pos_x: ")),-float(content[22].lstrip("            pos_y: ")))
						if instance.rotatable:
							instance.rotation_degrees = float(content[3].lstrip("            dir_z: "))
						if instance.scalable:
							instance.defaultSize = instance.scale
							instance.scale = Vector2(float(content[24].lstrip("            scale_x: ")),float(content[25].lstrip("            scale_y: ")))*instance.scale
						scene.nodes.append(instance)
						scene.add_child(instance)
						scene.connect("EXPORT", Callable(instance, "EXPORT"))
			if cycle <= 0:
				push_warning("ERR Not Recognized [" + content[0] + "]")
				content.remove_at(0)
	
	$CanvasLayer.hide()
	#print(content)
	for node in everypivotrail:
		node.changepivotpoint()
	
	scene.get_node("Cam").paused = false
	scene.disabledcontrolls = false
	scene.get_node("Cam").position = playerposition
	scene.get_node("Cam").zoom = Vector2(2.5,2.5)
	scene.get_node("Cam").toggleUI()


func _on_FileDialog_file_selected(path):
	var file = FileAccess.open(path, FileAccess.READ)
	
	
	var filename = str(path).get_file().left(str(path).get_file().length() - 1)
	filename = filename.erase(filename.length() - 3,3)
	content = file.get_as_text()
	
	file.close()
	LoadTest(filename)

