extends Rail
class_name MovingRail

const pointscene: PackedScene = preload("res://point.tscn")

@export var pointtexture: Texture2D = preload("uid://tmpumwmwcucm") #pointR.png
@export var railtexture: Texture2D = preload("uid://bw3l07oyd028f") #railwhite.png
@export var reset: int = 1
@export var midImage:Texture2D = null

var line = null
var mode = 0 #0 = path 1 = platform
var speed = 2


func focus_entered():
	$speed.visible = true

func focus_exited():
	$speed.visible = false

func _ready():
	var inst = load("res://rail.tscn").instantiate()
	add_child(inst)
	move_child(inst, 0)
	
	
	rail = inst
	rail.texture = railtexture
	$speed.connect("focus_entered", Callable(self, "focus_entered"))
	$speed.connect("focus_exited", Callable(self, "focus_exited"))
	$speed.position = $start.position - Vector2(0,100)
	get_parent().buttons.append($end/Button)
	$speed.text = str(speed)
	if loading == false:
		$start.position = Editor.roundedmousepos
		rail.add_point($start.position)
		rail.add_point($start.position)
		$preview.rail.points = rail.points
		idnum = Editor.idnum
		endplat[2] = "              id_name: rail" + str(idnum)
	else:
		$speed.hide()
	


@onready var endplat:PackedStringArray = ["              closed: CLOSE",
"              comment: !l -1",
"              id_name: rail" + str(idnum),
"              layer: LC",
"              link_info:",
"                - linkID: rail" + str(get_parent().idnum),
"                  param0: -1.00000",
"                  param1: -1.00000",
"                  param2: -1.00000",
"                  param3: -1.00000",
"                  param4: -1.00000",
"                  param5: -1.00000",
"                  param6: -1.00000",
"                  param7: -1.00000",
"                  type: Rail_Rail",
"              link_num: !l 1",
"              name: レール", #means rail
"              num_pnt: !l 3",
"              param0: "+str(Param0) + ".00000", #railtype
"              param1: 0.00000",#rotation for pivots
"              param2: " + str(speed) + ".00000", #speed
"              param3: "+str(reset),#-1 == does not reset on respawn, 1 == does
"              param4:  0.00000", #
"              param5: -1.00000",
"              param6: -1.00000",
"              param7: 1.00000", #
"              param8: -1.00000",
"              param9: -1.00000",
"              type: Linear",
"              unit_name: Path"]



func _process(delta):
	$speed.position = $start.position - Vector2(0,100)
	queue_redraw()
	if Input.is_action_just_pressed("accept"):
		$speed.hide()
	if locked == false and fillmode == false:
		if Input.is_action_just_pressed("addpoint"):
			newseg()
			
		if Input.is_action_just_pressed("bridge"):
			newseg()
			bridge()
	if Input.is_action_just_pressed("Shift"):
		fillmode = not fillmode

func add_point(pointID): #adds a point with the pointID value in the points array
	if pointID == points.size():
		pointID -= 1
	var newpoint = points[0].duplicate()
	add_child(newpoint)
	get_parent().buttons.insert(get_parent().points.size()-1+pointID,newpoint.get_node("Button"))
	points.insert(pointID,newpoint)
	rail.points = []

func remove_point(pointID):
	var point = points[pointID]
	var button = point.get_node("Button")
	rail.remove_point(pointID*2+1)
	rail.remove_point(pointID*2)
	segments -= 1
	if point != $end:
		points.remove_at(pointID)
		get_parent().buttons.erase(button)
		point.queue_free()
		var current_seg = 0
		points[0].make_big()
		for node in points: #redo segment numbers
			node.segments = current_seg
			current_seg += 1
			node.set_data()
	else:
		#remove the point before end and move end to it
		var newpoint = points[pointID-1]
		var newpos = newpoint.position
		get_parent().buttons.erase(newpoint.get_node("Button"))
		points.erase(newpoint)
		newpoint.queue_free()
		$end.position = newpos
		$start.position = $end.position
		$end.segments = segments-1
		$end.set_data()

func newseg():
	rail.add_point($end.position)
	rail.add_point($end.position)
	$preview.rail.points = rail.points
	var newpoint = pointscene.instantiate()
	newpoint.texture = pointtexture
	newpoint.position = $start.position
	if points.size() != 0:
		newpoint.comment = false #make it -dir instead of -comment
	add_child(newpoint)
	points.append(newpoint)
	get_parent().buttons.append(newpoint.get_node("Button"))
	newpoint.get_node("Button").connect("button_down", Callable(get_parent(), "_on_Button_button_down"))
	newpoint.get_node("Button").connect("button_up", Callable(get_parent(), "_on_Button_button_up"))
	$end.set_data()
	segments += 1
	
	if segments == 2:
		newpoint.get_node("start").stop()
		newpoint.frame = 0
	$start.position = $end.position
	$start.frame = 1

func done():
	if mode == 0:
		points.append($end)
		$end.segments = segments-1
		$end.set_data()
		Editor.idnum += 1
		locked = true
		Editor.lineplacing = true

func bridge():
	if mode == 0:
		done()
		$speed.grab_focus()
		$speed.set_caret_column(3)

func _draw():
	if locked == false and loading == false:
		if !fillmode:
			$end.position = Editor.roundedmousepos
		pointcurve()
	draw_line($start.position,$end.position,color,4.5)
	#draw the image that appears between the points (fan)
	if midImage != null:
		$Mid.show()
		$Mid.texture = midImage
		$Mid.position = get_parent().points[0].position
	else:
		$Mid.hide()

func EXPORT():
	Editor.bridgedata += get_parent().get_data() + get_parent().end + get_data() + endplat

func _on_speed_change():
	speed = float($speed.text)
	var loop = 0
	for dat in endplat:
		if dat.begins_with("              param2:"):
			break
		loop += 1
	endplat[loop] = "              param2: " + str(speed)
	$preview.repeat = true
