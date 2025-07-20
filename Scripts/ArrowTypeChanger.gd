extends Node

func _ready():
	owner.texture = preload("res://Arrow.png")
	var ArrowButton = owner.get_node("Button")
	ArrowButton.position = Vector2(66,-169)
	ArrowButton.size = Vector2(133,95)
	match owner.ObjectName:
		"Dkb_ChalkYajirushi_Kaiten":
			owner.texture = preload("res://ArrowKaiten.png")
			ArrowButton.position = Vector2(-162,-66)
			ArrowButton.size = Vector2(353,132)
		"Dkb_ChalkYajirushi_Arrow":
			owner.texture = preload("res://BigArrow.png")
			ArrowButton.position = Vector2(-184,-147)
			ArrowButton.size = Vector2(368,287)
		"Dkb_ChalkYajirushi_45":
			owner.texture = preload("res://Arrow45.png")
			ArrowButton.position = Vector2(37,-213)
			ArrowButton.size = Vector2(103,81)
		"Dkb_ChalkYajirushi_90":
			owner.texture = preload("res://Arrow90.png")
			ArrowButton.position = Vector2(15,-213)
			ArrowButton.size = Vector2(206,191)
		"Dkb_ChalkYajirushi_180":
			owner.texture = preload("res://Arrow180.png")
			ArrowButton.position = Vector2(-118,-206)
			ArrowButton.size = Vector2(287,199)

#func _process(delta):
#	if owner.data[3] == "            dir_z: 45.00000":
#		owner.scale.x = -0.136
#	else:
#		owner.scale.x = 0.136
