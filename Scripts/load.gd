extends Button

@onready var file = get_parent().get_node("FileDialog")
var path = null
var content
var loaded = false
var rail = false


func _on_load_pressed():
	file.current_path = Options.filepath
	file.popup()

func _process(delta):
	if loaded == false:
		if Input.is_action_just_pressed("Paste"):
			content = OS.clipboard
			$AnimationPlayer.play("transition")
			Load("untitled")


func _on_FileDialog_confirmed():
	path = file.current_path
	var file = File.new()
	file.open(path, File.READ)
	
	var name = str(path).get_file().left(str(path).get_file().length() - 1)
	name = name.left(name.length() - 1)
	name = name.left(name.length() - 1)
	name = name.left(name.length() - 1)
	
	content = file.get_as_text()
	
	file.close()
	Load(name)






func Load(data):
	var name = data
	self_modulate = Color(1,1,1,0)
	$AnimationPlayer.play("transition")
	var timer = Timer.new()
	add_child(timer)
	timer.start(.05)
	await timer.timeout;
	
	
	
	
	
	
	
	
	content = str(content)
	
	print(name)
	
	content = content.split("\n")
	
	var cycle = 8
	loaded = true
	get_parent().get_node("RichTextLabel").hide()
	get_parent().get_node("bfg").hide()
	get_parent().get_node("new").hide()
	get_parent().get_node("logo").hide()
	get_parent().get_node("settings").hide()
	get_parent().get_node("quit").hide()
	get_parent().get_node("help").hide()
	get_parent().get_node("FileDialog").queue_free()
	
	get_parent().add_child(preload("res://Creator.tscn").instantiate())
	
	var scene = get_parent().get_node("Editor")
	scene.get_node("Cam").current = true
	scene.get_node("nonmoving/name").text = name
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
	for line in content:
		overide = 0
		cycle -= 1
		
		#check wether to switch to rails
		if content[0] == "            - Points:":
			if ignore == 0:
				railinterested = true
			else:
				ignore -= 1
		
		if railinterested == true:
			
			trackedinfo.append(content[0])
			if trackedinfo[trackedinfo.size()-1].begins_with("                - dir_x:"):
				if trackedinfo[trackedinfo.size()-2].begins_with("                - dir_x:"):
					trackedinfo.remove_at(trackedinfo.size()-1)
			if trackedinfo[trackedinfo.size()-1].begins_with("                - comment: !l -1"):
				if trackedinfo[trackedinfo.size()-2].begins_with("                - comment: !l -1"):
					trackedinfo.remove_at(trackedinfo.size()-1)
			
			
			
		if content[0].begins_with("              closed:"):
			if railinterested == true:
				var keepthis = trackedinfo[trackedinfo.size()-1]
				trackedinfo.remove_at(trackedinfo.size()-1)
				actualrail = rail
				if railtype == "turn":
					actualrail = rail.get_node("Spin")
				
				actualrail.data = trackedinfo
				if trackedinfo[1] == "            - Points:":
					
					
					actualrail.data.remove_at(1)
				trackedinfo = []
				trackedinfo.append(keepthis)
		if content[0].begins_with("              unit_name: "):
			if railinterested == true:
				if railtype == "fan":
					actualrail.endplat = trackedinfo
				else:
					print(railtype)
					if railtype == "fanchild":
						actualrail.endplat = trackedinfo
					else:
						if railtype == "none":
							actualrail.endplat = trackedinfo
						else:
							actualrail.end = trackedinfo
							print(trackedinfo)
				
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
		
		

		if cycle + 1 > 0:
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
					cycle = 25
					if railtype != "fanchild":
						#rail = preload("res://bridge.tscn").instance()
						var id = 0
						var pre = 0
						for line2 in content:
							pre += 1
							if line2 == "              closed: CLOSE":
								if pre > -1:
									print("YES")
									id = pre +7
									pre = -999999999
						
						print(content[id])
						if content[id] == "              param0: 2900.00000":
							print("pathrail detexted")
							pre = -1
							
							var stage = 0
							for line3 in content:
								pre += 1
								if line3 == "              closed: CLOSE":
									if stage == 1:
										nextid = pre + 19
										print(content[nextid])
										railtype = "fan"
										if str(content[nextid]).begins_with("              param1:"):
											nextid -= 1
									stage += 1
						
						if nextid < content.size():
							
							if content[nextid] == "              param0: 2141.00000":
								print("aR")
								rail = preload("res://R.tscn").instantiate()
								rail.speed = float(str(content[nextid + 2]).replace("              param2: ",""))
							if content[nextid] == "              param0: 2392.00000":
								print("anEndMove")
								rail = preload("res://EndMove.tscn").instantiate()
								rail.speed = float(str(content[nextid + 2]).replace("              param2: ",""))
							if content[nextid] == "              param0: 2200.00000":
								print("Auto")
								rail = preload("res://Auto.tscn").instantiate()
								rail.speed = float(str(content[nextid + 2]).replace("              param2: ",""))
							if content[nextid] == "              param0: 2000.00000":
								print("Auto")
								rail = preload("res://Auto.tscn").instantiate()
								rail.speed = float(str(content[nextid + 2]).replace("              param2: ",""))
							if content[nextid] == "              param0: 2300.00000":
								print("Auto")
								rail = preload("res://Auto.tscn").instantiate()
								rail.speed = float(str(content[nextid + 2]).replace("              param2: ",""))
							if content[nextid] == "              param0: 2110.00000":
								print("LCrnaked")
								rail = preload("res://lcrankrail.tscn").instantiate()
								rail.speed = float(str(content[nextid + 2]).replace("              param2: ",""))
							if content[nextid] == "              param0: 2111.00000":
								print("RsCrnaked")
								rail = preload("res://RCrankRail.tscn").instantiate()
								rail.speed = float(str(content[nextid + 2]).replace("              param2: ",""))
							if content[nextid] == "              param0: 2150.00000":
								print("afan")
								rail = preload("res://fan.tscn").instantiate()
								rail.speed = float(str(content[nextid + 2]).replace("              param2: ",""))
								print(str(content[nextid + 2]))
							if content[nextid] == "              param0: 2140.00000":
								print("aL")
								rail = preload("res://L.tscn").instantiate()
								rail.speed = float(str(content[nextid + 2]).replace("              param2: ",""))
						if content[id] == "              param0: 1000.00000":
							print("aL")
							rail = preload("res://bridge.tscn").instantiate()
							railtype = "normal"
						
						if content[id] == "              param0: 0.00000":
							rail = preload("res://bridge.tscn").instantiate()
							rail.invisible = true
							railtype = "normal"
						if content[id] == "              param0: 1200.00000":
							print("blue")
							rail = preload("res://bridge.tscn").instantiate()
							railtype = "normal"
							rail.color = Color(.13,.58,.87,1)
						if content[id] == "              param0: 5013.00000":
							rail = preload("res://bridge.tscn").instantiate()
							railtype = "normal"
						if content[id] == "              param0: 3111.00000":
							print("aL")
							rail = preload("res://Rspin.tscn").instantiate()
							rail.get_node("Spin").loading = true
							rail.get_node("Spin/rotation").text = str(-int(str(content[id + 1]).lstrip("              param1: ")))
							rail.get_node("Spin/rotation").prev = rail.get_node("Spin/rotation").text
							railtype = "turn"
						if content[id] == "              param0: 3140.00000":
							print("aL")
							rail = preload("res://Lpivot.tscn").instantiate()
							rail.get_node("Spin").loading = true
							rail.get_node("Spin/rotation").text = str(-int(str(content[id + 1]).lstrip("              param1: ")))
							rail.get_node("Spin/rotation").prev = rail.get_node("Spin/rotation").text
							railtype = "turn"
						if content[id] == "              param0: 3300.00000":
							print("aL")
							rail = preload("res://Apivot.tscn").instantiate()
							rail.get_node("Spin").loading = true
							rail.get_node("Spin/rotation").text = str(-int(str(content[id + 1]).lstrip("              param1: ")))
							rail.get_node("Spin/rotation").prev = rail.get_node("Spin/rotation").text
							railtype = "turn"
						if content[id] == "              param0: 3392.00000":
							print("aL")
							rail = preload("res://Endpivot.tscn").instantiate()
							rail.get_node("Spin").loading = true
							rail.get_node("Spin/rotation").text = str(-int(str(content[id + 1]).lstrip("              param1: ")))
							rail.get_node("Spin/rotation").prev = rail.get_node("Spin/rotation").text
							railtype = "turn"
						if content[id] == "              param0: 3141.00000":
							print("aL")
							rail = preload("res://Rpivot.tscn").instantiate()
							rail.get_node("Spin").loading = true
							rail.get_node("Spin/rotation").text = str(-int(str(content[id + 1]).lstrip("              param1: ")))
							rail.get_node("Spin/rotation").prev = rail.get_node("Spin/rotation").text
							railtype = "turn"
						if content[id] == "              param0: 2392.00000":
							railtype = "link"
						if content[id] == "              param0: 3112.00000":
							print("LSpijviot")
							rail = preload("res://LSpivit.tscn").instantiate()
							railtype = "norm"
							rail.get_node("Spin").loading = true
							rail.get_node("Spin/rotation").text = str(-int(str(content[id + 1]).lstrip("              param1: ")))
							rail.get_node("Spin/rotation").prev = rail.get_node("Spin/rotation").text
							railtype = "turn"
						if content[id] == "              param0: 3113.00000":
							print("RSpijviot")
							rail = preload("res://RSpivit.tscn").instantiate()
							railtype = "norm"
							rail.get_node("Spin").loading = true
							rail.get_node("Spin/rotation").text = str(-int(str(content[id + 1]).lstrip("              param1: ")))
							rail.get_node("Spin/rotation").prev = rail.get_node("Spin/rotation").text
							railtype = "turn"
					rail.loading = true
					if rail.get_node_or_null("start") == null:
						rail.get_node("Spin/start").position = Vector2(int(content[12].lstrip("                  pnt0_x: ")),-int(content[13].lstrip("                  pnt0_y: ")))
					else:
						rail.get_node("start").position = Vector2(int(content[12].lstrip("                  pnt0_x: ")),-int(content[13].lstrip("                  pnt0_y: ")))
					if railtype != "fanchild":
						scene.connect("EXPORT", Callable(rail, "EXPORT"))
						scene.add_child(rail)
						scene.nodes.append(rail)
				if content[0] == "                - comment: !l -1" and overide != 1:
					
					if rail.get_node_or_null("end") == null:
						rail.get_node("Spin/end").position = Vector2(int(content[11].lstrip("                  pnt0_x: ")),-int(content[12].lstrip("                  pnt0_y: ")))
					else:
						rail.get_node("end").position = Vector2(int(content[11].lstrip("                  pnt0_x: ")),-int(content[12].lstrip("                  pnt0_y: ")))
					if content[24] == "              closed: CLOSE":
						if railtype == "link":
							cycle = 54
						else:
							cycle = 44
						rail.newseg()
						if railtype == "fan":
							if str(content[56]).begins_with("                  pnt0_y:"):
								rail.done(Vector2(int(content[56].lstrip("                  pnt0_x: ")),-int(content[57].lstrip("                  pnt0_y: "))))
							else:
								rail.done(Vector2(int(content[57].lstrip("                  pnt0_x: ")),-int(content[58].lstrip("                  pnt0_y: "))))
						else:
							rail.done()
							
							if railtype == "noise":
								rail.end[8] = "              param0: 5013.00000"
							
						
						if railtype == "fanchild":
							railtype = "none"
							cycle = 54
						
						if railtype == "fan":
							rail = rail.childrail
							railtype = "fanchild"
							rail.loading = true
							overide = 1
						
						
					else:
						cycle = 24
						rail.newseg()
				if content[0] == "                - dir_x: 0.00000" and overide != 1:
					if rail.get_node_or_null("end") == null:
						rail.get_node("Spin/end").position = Vector2(int(content[10].lstrip("                  pnt0_x: ")),-int(content[11].lstrip("                  pnt0_y: ")))
					else:
						rail.get_node("end").position = Vector2(int(content[10].lstrip("                  pnt0_x: ")),-int(content[11].lstrip("                  pnt0_y: ")))
					if content[23] == "              closed: CLOSE":
						cycle = 43
						rail.newseg()
						if railtype == "fan":
							if str(content[56]).begins_with("                  pnt0_y:"):
								rail.done(Vector2(int(content[55].lstrip("                  pnt0_x: ")),-int(content[56].lstrip("                  pnt0_y: "))))
							else:
								rail.done(Vector2(int(content[56].lstrip("                  pnt0_x: ")),-int(content[57].lstrip("                  pnt0_y: "))))
						else:
							rail.done()
						
						
						if railtype == "fanchild":
							railtype = "none"
							cycle = 54
						
						if railtype == "fan":
							rail = rail.childrail
							railtype = "fanchild"
							overide = 1
						
						
					else:
						cycle = 23
						rail.newseg()
					
				if content[0] == "        RailInfos:":
					cycle = 278
					
				
			else:
				cycle = 27
				
				if content[8] == "            name: Dkb_Player":
					var player = preload("res://player.tscn").instantiate()
					player.position = Vector2(int(content[21].lstrip("            pos_x: ")),-int(content[22].lstrip("            pos_y: ")))
					instance = player
					scene.get_node("Cam").position = player.position
					scene.get_node("CanvasLayer3/CanvasLayer/buttons").play("out")
					scene.stored = player
				if content[8] == "            name: Dkb_CheckPoint":
					if content[9] == "            param0: 2.00000":
						instance = preload("res://finalcheckpoint.tscn").instantiate()
					else:
						instance = preload("res://checkpoint.tscn").instantiate()
				if content[8] == "            name: Dkb_Banana":
					instance = preload("res://banana.tscn").instantiate()
				if content[8] == "            name: Dkb_ChalkEntrance":
					instance = preload("res://door.tscn").instantiate()
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
				if content[8] == "            name: Dkb_ChalkBarrel":
					instance = preload("res://barrel.tscn").instantiate()
				
				if instance != null:
					instance.position = Vector2(int(content[21].lstrip("            pos_x: ")),-int(content[22].lstrip("            pos_y: ")))
					scene.nodes.append(instance)
					scene.add_child(instance)
					scene.connect("EXPORT", Callable(instance, "EXPORT"))
					
			if cycle <= 0:
				print("ERR Not Recognized [" + content[0] + "]")
				content.remove_at(0)
	#print(content)
	
	
	#So far, the tracked info only works for objects and isn't implemented yet
