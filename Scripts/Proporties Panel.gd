extends Sprite2D

const object = preload("res://Function Presets/Object.tscn")
const check = preload("res://Function Presets/Checkpoint.tscn")
const bridge = preload("res://Function Presets/Bridge.tscn")
const moving = preload("res://Function Presets/MovingPlatform.tscn")
const movingend = preload("res://Function Presets/MovingPlatformEnd.tscn")
const auto = preload("res://Function Presets/Auto.tscn")
const rotating = preload("res://Function Presets/RotatingRails.tscn")
const endrotate = preload("res://Function Presets/RotatingRailsEnd.tscn")
const apivot = preload("res://Function Presets/AutoRotate.tscn")

var previousParam0 = ""

func add_function_preset():#give it the right presets
	for node in $FunctionContainer.get_children():
		$FunctionContainer.remove_child(node)
	
	if not owner.editednode.is_in_group("Object"):
		previousParam0 = owner.editednode.end[8]
		if owner.editednode.is_in_group("PathRail"):
			previousParam0 = owner.editednode.childrail.endplat[18]
		print(owner.editednode.childrail.name,previousParam0)
		
	if owner.editednode.is_in_group("Rail"):
		$FunctionContainer.add_child(bridge.instantiate())
	#Moving Platforms
	if owner.editednode.is_in_group("Moving"):
		if owner.editednode.is_in_group("AutoMove"):
			$FunctionContainer.add_child(auto.instantiate())
		elif owner.editednode.is_in_group("EndMove"):
			$FunctionContainer.add_child(movingend.instantiate())
		else:
			$FunctionContainer.add_child(moving.instantiate())
	#Rotating Platforms
	if owner.editednode.is_in_group("Spin"):
		if owner.editednode.is_in_group("EndSpin"):
			$FunctionContainer.add_child(endrotate.instantiate())
		elif owner.editednode.is_in_group("AutoSpin"):
			$FunctionContainer.add_child(apivot.instantiate())
		else:
			$FunctionContainer.add_child(rotating.instantiate())
			
	
	#Objects
	if owner.editednode.is_in_group("checkpoint"):
		$FunctionContainer.add_child(check.instantiate())
	if $FunctionContainer.get_child_count() == 0:
		var instance = object.instantiate()
		$FunctionContainer.add_child(instance)
		if owner.editednode.scalable == true:
			for node in instance.get_children():
				if node.is_in_group("scale"):
					node.show()
		if owner.editednode.rotatable == true:
			for node in instance.get_children():
				if node.is_in_group("rotate"):
					node.show()

func _on_Functions_pressed():
	$ScrollContainer.hide()
	$FunctionContainer.show()
	


func _on_Property_pressed():
	$ScrollContainer.show()
	$FunctionContainer.hide()

func datachanged(_text):
	if $RealTime.button_pressed: #if it's realtime
		$ScrollContainer/VBox.applydata()
		if not owner.editednode.is_in_group("Object"):
			if owner.editednode.is_in_group("PathRail"):
				if previousParam0 != owner.editednode.childrail.endplat[18]:
					add_function_preset()
					previousParam0 = owner.editednode.childrail.endplat[18]
			else:
				if previousParam0 != owner.editednode.end[8]:
					add_function_preset()
					previousParam0 = owner.editednode.end[8]
