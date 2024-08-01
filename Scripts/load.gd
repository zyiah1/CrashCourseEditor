extends Button

@onready var fileDialog = get_parent().get_node("FileDialog")
var content
var loaded = false
var rail = false


func _on_load_pressed():
	fileDialog.current_path = Options.filepath
	fileDialog.popup_centered(Vector2(1600,800))

func _process(delta):
	if loaded == false:
		if Input.is_action_just_pressed("Paste"):
			content = DisplayServer.clipboard_get()
			$AnimationPlayer.play("transition")
			Load("untitled")








func Load(filename):
	self_modulate = Color(1,1,1,0)
	$AnimationPlayer.play("transition")
	var timer = Timer.new()
	add_child(timer)
	timer.start(.05)
	await timer.timeout;
	content = str(content)
	content = content.split("\n")
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
	
	while content.size()>0:
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
		
		
		if cycle + 1 > 0:#remove whatever amount the cycle is (CHANGE THIS TO A SIMPLE ERASE COMMAND PLEASE)
			content.remove_at(0)
		else:
			
			
			if content[0] == "              param2: 0.20000":
				cycle = 10
			
			if content[0] == "                  dir_x: 0.00000":
				content.insert(0,"            - Points:")
			if content[0] == "                  dir_y: 0.00000":
				cycle = 42
			if content[0] != "          - comment: !l -1":
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
							
							if content[nextid] == "              param0: 2141.00000":
								rail = preload("res://R.tscn").instantiate()
							if content[nextid] == "              param0: 2392.00000":
								rail = preload("res://EndMove.tscn").instantiate()
								
							if content[nextid] == "              param0: 2200.00000":
								rail = preload("res://Auto.tscn").instantiate()
							if content[nextid] == "              param0: 2300.00000":
								rail = preload("res://Auto.tscn").instantiate()
							if content[nextid] == "              param0: 2000.00000":
								rail = preload("res://Auto.tscn").instantiate()
							if content[nextid] == "              param0: 4300.00000":
								rail = preload("res://Auto.tscn").instantiate()
							if content[nextid] == "              param0: 2110.00000":
								rail = preload("res://lcrankrail.tscn").instantiate()
							if content[nextid] == "              param0: 2111.00000":
								rail = preload("res://RCrankRail.tscn").instantiate()
							if content[nextid] == "              param0: 2150.00000":
								rail = preload("res://fan.tscn").instantiate()
							if content[nextid] == "              param0: 2140.00000":
								rail = preload("res://L.tscn").instantiate()
							if content[nextid].begins_with("              param0: 2"):
								if not rail in scene.nodes:
									rail.speed = float(str(content[nextid + 2]).replace("              param2: ",""))
									
								else:
									push_error("Rail is already in the scene! nextID:"+content[nextid])
									push_error(content[nextid-6])
							#print(content[nextid])
							
						if content[id] == "              param0: 1000.00000" or content[id] == "              param0: 1100.00000"  or content[id] == "              param0: 5013.00000" or content[id] == "              param0: 5060.00000" or content[id] == "              param0: 5040.00000" or content[id] == "              param0: 5041.00000" or content[id] == "              param0: 5260.00000" or content[id] == "              param0: 5211.00000" or content[id] == "              param0: 5240.00000" or content[id] == "              param0: 5241.00000" or content[id] == "              param0: 3090.00000"or content[id] == "              param0: 3040.00000" or content[id] == "              param0: 2423.00000"or content[id] == "              param0: 3160.00000"or content[id] == "              param0: 3080.00000"or content[id] == "              param0: 2423.00000" or content[id] == "              param0: 5250.00000" or content[id] == "              param0: 5020.00000":
							rail = preload("res://bridge.tscn").instantiate()
							railtype = "normal"
						if content[id] == "              param0: 0.00000":
							rail = preload("res://bridge.tscn").instantiate()
							rail.invisible = true
							railtype = "normal"
						if content[id] == "              param0: 1200.00000":
							rail = preload("res://bridge.tscn").instantiate()
							railtype = "normal"
							rail.color = Color(.13,.58,.87,1)
						if content[id] == "              param0: 5100.00000"  or content[id] == "              param0: 6000.00000" :
							rail = preload("res://musicrail.tscn").instantiate()
							railtype = "normal"
						if content[id] == "              param0: 3110.00000" or content[id] == "              param0: 3010.00000" :
							rail = preload("res://Lspin.tscn").instantiate()
						if content[id] == "              param0: 3111.00000" or content[id] == "              param0: 3011.00000" :
							rail = preload("res://Rspin.tscn").instantiate()
						if content[id] == "              param0: 3140.00000":
							rail = preload("res://Lpivot.tscn").instantiate()
						if content[id] == "              param0: 3150.00000":
							rail = preload("res://Lpivot.tscn").instantiate()
							push_error("Figure this one out please")
						if content[id] == "              param0: 3300.00000" or content[id] == "              param0: 3200.00000" or content[id] == "              param0: 3423.00000" or content[id] == "              param0: 3322.00000":
							rail = preload("res://Apivot.tscn").instantiate()
						if content[id] == "              param0: 3392.00000":
							rail = preload("res://Endpivot.tscn").instantiate()
						if content[id] == "              param0: 3141.00000":
							rail = preload("res://Rpivot.tscn").instantiate()
						if content[id] == "              param0: 3112.00000":
							rail = preload("res://LSpivit.tscn").instantiate()
						if content[id] == "              param0: 3113.00000":
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
				
				if content[8] == "            name: Dkb_Player":
					var player = preload("res://player.tscn").instantiate()
					player.position = Vector2(int(content[21].lstrip("            pos_x: ")),-int(content[22].lstrip("            pos_y: ")))
					instance = player
					scene.get_node("Cam").position = player.position
					scene.get_node("CanvasLayer3/CanvasLayer/buttons").play("out")
					scene.stored = player
				if content[8] == "            name: Dkb_CheckPoint":
					if content[9].begins_with("            param0: 2.00000"):
						instance = preload("res://finalcheckpoint.tscn").instantiate()
					else:
						instance = preload("res://checkpoint.tscn").instantiate()
						if content[9].begins_with("            param0: 1"):
							instance.changetofirst()
					if content[24] == "            scale_x: -1.00000":
						instance.flip_h = true
				if content[8] == "            name: Dkb_Banana":
					instance = preload("res://banana.tscn").instantiate()
				if content[8] == "            name: Dkb_ChalkEntrance":
					push_warning("Entrance")
					instance = preload("res://door.tscn").instantiate()
				if content[8] == "            name: Dkb_ChalkRainbow":
					instance = preload("res://door.tscn").instantiate()
					instance.texture = preload("res://rainbow.png")
					instance.offset.y = 0
				if content[8] == "            name: Dkb_OneUpItem":
					instance = preload("res://1up.tscn").instantiate()
				if content[8] == "            name: Dkb_Coin":
					instance = preload("res://coin.tscn").instantiate()
				if content[8] == "            name: Dkb_ChalkDonkey":
					instance = preload("res://dk.tscn").instantiate()
				if content[8] == "            name: Dkb_ChalkPauline":
					instance = preload("res://pauline.tscn").instantiate()
				if content[8] == "            name: Dkb_ChalkBag":
					instance = preload("res://purse.tscn").instantiate()
				if content[8] == "            name: Dkb_ChalkYajirushi_Kaiten":
					instance = preload("res://Arrow.tscn").instantiate()
					instance.type = "rotate"
				if content[8] == "            name: Dkb_ChalkYajirushi_Arrow":
					instance = preload("res://Arrow.tscn").instantiate()
					instance.type = "big"
				if content[8] == "            name: Dkb_ChalkYajirushi_45":
					instance = preload("res://Arrow.tscn").instantiate()
					instance.type = "45"
				if content[8] == "            name: Dkb_ChalkYajirushi_90":
					instance = preload("res://Arrow.tscn").instantiate()
					instance.type = "90"
				if content[8] == "            name: Dkb_ChalkYajirushi_180":
					instance = preload("res://Arrow.tscn").instantiate()
					instance.type = "180"
				if content[8] == "            name: Dkb_ChalkYajirushi_00":
					instance = preload("res://Arrow.tscn").instantiate()
				if content[8] == "            name: Dkb_ChalkUmbrella":
					instance = preload("res://hammer.tscn").instantiate()
				if content[8] == "            name: Dkb_ChalkLadder":
					instance = preload("res://ladder.tscn").instantiate()
					instance.loading = true
					
					match int(content[9].lstrip("            param0: ")):
						1:
							instance.texture = preload("res://ladder1.png")
						2:
							instance.texture = preload("res://ladder2.png")
						#3:
							
						4:
							instance.texture = preload("res://ladder4.png")
						5:
							instance.texture = preload("res://ladder5.png")
						6:
							instance.texture = preload("res://ladder6.png")
				if content[8] == "            name: Dkb_ChalkBarrel":
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
	
	#print(content)
	for node in everypivotrail:
		node.changepivotpoint()
	


func _on_FileDialog_file_selected(path):
	var file = FileAccess.open(path, FileAccess.READ)
	
	
	var filename = str(path).get_file().left(str(path).get_file().length() - 1)
	filename = filename.erase(filename.length() - 3,3)
	content = file.get_as_text()
	
	file.close()
	Load(filename)

