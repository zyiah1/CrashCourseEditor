extends Sprite2D

@onready var id = get_parent().nodes.size()

@export var ObjectName:String = "Dkb_Banana"

@export var Param0: float = -1
@export var Param1: float = -1
@export var Param10: float = -1
@export var Param11: float = -1
@export var Param2: float = -1
@export var Param3: float = -1
@export var Param4: float = -1
@export var Param5: float = -1
@export var Param6: float = -1
@export var Param7: float = -1
@export var Param8: float = -1
@export var Param9: float = -1

@export var PosZ: float = 0

@export var rotatable: bool = true
@export var scalable: bool = true

@export var defaultSize = Vector2(.125,.125)

@onready var data:PackedStringArray = [
		  "          - comment: !l -1",
			"            dir_x: 0.00000",
			"            dir_y: 0.00000",
			"            dir_z: 0.00000",
			"            id_name: obj" + str(get_parent().idnum),
			"            layer: LC",
			"            link_info: []",
			"            link_num: !l 0",
			"            name: "+ObjectName,
			"            param0: "+str(Param0), #maybe points rewarded (banana)
			"            param1: "+str(Param1),
			"            param10: "+str(Param10),
			"            param11: "+str(Param11),
			"            param2: "+str(Param2),
			"            param3: "+str(Param3),
			"            param4: "+str(Param4),
			"            param5: "+str(Param5),
			"            param6: "+str(Param6),
			"            param7: "+str(Param7),
			"            param8: "+str(Param8),
			"            param9: "+str(Param9),
			"            pos_x: " + str(position.x),
			"            pos_y: " + str(-position.y),
			"            pos_z: " + str(PosZ),
			"            scale_x: 1.00000",
			"            scale_y: 1.00000",
			"            scale_z: 1.00000"]

var previouspos: Vector2

func _ready():
	get_parent().idnum += 1

func _on_Button_button_up():
	if previouspos != position and get_parent().item != "delete" and get_parent().item != "proporties" :
		get_parent().undolistadd({"Type":"Move","Data":[previouspos,position],"Node":self})

func _on_Button_button_down():
	if get_parent().item == "delete":
		get_parent().nodes.remove_at(id)
		if get_parent().stored == self:
			get_parent().playerunstore()
		hide()
		get_parent().undolistadd({"Type":"Delete","Node":self})
		add_to_group("Limbo")
	if get_parent().item == "proporties":
		if get_parent().propertypanel == false:
			get_parent().propertypanel = true
			data[21] = "            pos_x: " + str(position.x)
			data[22] = "            pos_y: " + str(-position.y)
			get_parent().parse(data)
			get_parent().editednode = self
			return
	previouspos = position

func _process(delta):
	id = get_parent().nodes.find(self)
	if $Button.is_hovered():
		match get_parent().item:
			"edit":
				modulate = Color.GREEN_YELLOW
			"delete":
				modulate = Color.RED
			"proporties":
				modulate = Color.LIGHT_SKY_BLUE
	else:
		modulate = Color.WHITE
	if get_parent().item != "proporties" and get_parent().item != "edit" and $Button.button_pressed:
		position = get_global_mouse_position().round()


func reposition():
	position.x = float(data[21].lstrip("            pos_x: "))
	position.y = -float(data[22].lstrip("            pos_y: "))
	if scalable:
		scale.x = float(data[24].lstrip("            scale_x: "))
		scale.y = float(data[25].lstrip("            scale_y: "))
		scale = scale*defaultSize #cause I'm stupid and everythings default scale is not 1
	if rotatable:
		rotation_degrees = float(data[3].lstrip("            dir_z: "))

func EXPORT():
	if visible:
		data[21] = "            pos_x: " + str(position.x)
		data[22] = "            pos_y: " + str(-position.y)
		get_parent().objects += data
