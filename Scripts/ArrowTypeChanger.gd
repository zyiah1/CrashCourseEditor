extends Node

func _ready():
	owner.texture = preload("res://Arrow.png")
	var ArrowButton = owner.get_node("Button")
	ArrowButton.position = Vector2(66,-169)
	ArrowButton.size = Vector2(133,95)
	match owner.ObjectName:
		"Dkb_ChalkYajirushi_Kaiten":
			owner.texture = preload("res://ArrowKaiten.png")
			owner.offset = Vector2(0,0)
			ArrowButton.position = Vector2(-162,-66)
			ArrowButton.size = Vector2(353,132)
		"Dkb_ChalkYajirushi_Arrow":
			owner.texture = preload("res://BigArrow.png")
			owner.offset = Vector2(0,0)
			ArrowButton.position = Vector2(-184,-147)
			ArrowButton.size = Vector2(368,287)
		"Dkb_ChalkYajirushi_00":
			owner.texture = preload("res://Arrow.png")
			owner.offset = Vector2(130,-126)
			ArrowButton.position = Vector2(66,-169)
			ArrowButton.size = Vector2(133,95)
		"Dkb_ChalkYajirushi_45":
			owner.texture = preload("res://Arrow45.png")
			owner.offset = Vector2(130,-126)
			ArrowButton.position = Vector2(37,-213)
			ArrowButton.size = Vector2(103,81)
		"Dkb_ChalkYajirushi_90":
			owner.texture = preload("res://Arrow90.png")
			owner.offset = Vector2(130,-126)
			ArrowButton.position = Vector2(15,-213)
			ArrowButton.size = Vector2(206,191)
		"Dkb_ChalkYajirushi_180":
			owner.texture = preload("res://Arrow180.png")
			owner.offset = Vector2(0,-115)
			ArrowButton.position = Vector2(-118,-206)
			ArrowButton.size = Vector2(287,199)
	ArrowButton.connect("button_down",Callable(self,"FlipArrow"))

func FlipArrow():
	if owner.get_node("Button").button_pressed and owner.get_parent().item == "edit":
		
		if owner.data[9].begins_with("            param0: 1"):
			owner.data[9] = "            param0: -1.00000"
		else:
			owner.data[9] = "            param0: 1.00000"

func _process(delta):
	if owner.data[9].begins_with("            param0: 1"):
		owner.flip_h = true
	else:
		owner.flip_h = false
	
