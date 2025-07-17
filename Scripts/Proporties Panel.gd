extends Sprite2D

const object = preload("res://Function Presets/Object.tscn")
const check = preload("res://Function Presets/Checkpoint.tscn")
const bridge = preload("res://Function Presets/Bridge.tscn")
const moving = preload("res://Function Presets/MovingPlatform.tscn")
const movingend = preload("res://Function Presets/MovingPlatformEnd.tscn")
const auto = preload("res://Function Presets/Auto.tscn")
const rotating = preload("res://Function Presets/RotatingRails.tscn")
const apivot = preload("res://Function Presets/AutoRotate.tscn")

func _on_Functions_pressed():
	if $ScrollContainer.visible == true:
		for node in $FunctionContainer.get_children():
			$FunctionContainer.remove_child(node)
		$ScrollContainer.hide()
		$FunctionContainer.show()
		
		#give it the right presets
		
		
		if get_parent().get_parent().editednode.is_in_group("bridge"):
			$FunctionContainer.add_child(bridge.instantiate())
		if get_parent().get_parent().editednode.is_in_group("music"):
			$FunctionContainer.add_child(bridge.instantiate())
		if get_parent().get_parent().editednode.is_in_group("FanMove"):
			$FunctionContainer.add_child(moving.instantiate())
		if get_parent().get_parent().editednode.is_in_group("RMove"):
			$FunctionContainer.add_child(moving.instantiate())
		if get_parent().get_parent().editednode.is_in_group("LMove"):
			$FunctionContainer.add_child(moving.instantiate())
		if get_parent().get_parent().editednode.is_in_group("AutoMove"):
			$FunctionContainer.add_child(auto.instantiate())
		if get_parent().get_parent().editednode.is_in_group("Autospin"):
			$FunctionContainer.add_child(apivot.instantiate())
		if get_parent().get_parent().editednode.is_in_group("Lcrank"):
			$FunctionContainer.add_child(moving.instantiate())
		if get_parent().get_parent().editednode.is_in_group("Rcrank"):
			$FunctionContainer.add_child(moving.instantiate())
		if get_parent().get_parent().editednode.is_in_group("EndMove"):
			$FunctionContainer.add_child(movingend.instantiate())
		if get_parent().get_parent().editednode.is_in_group("Spin"):
			$FunctionContainer.add_child(rotating.instantiate())
		if get_parent().get_parent().editednode.is_in_group("checkpoint"):
			$FunctionContainer.add_child(check.instantiate())
		if $FunctionContainer.get_child_count() == 0:
			var instance = object.instantiate()
			$FunctionContainer.add_child(instance)
			if get_parent().get_parent().editednode.scalable == true:
				for node in instance.get_children():
					if node.is_in_group("scale"):
						node.show()
			if get_parent().get_parent().editednode.rotatable == true:
				for node in instance.get_children():
					if node.is_in_group("rotate"):
						node.show()

func _on_Property_pressed():
	$ScrollContainer.show()
	$FunctionContainer.hide()

func datachanged(text):
	if $RealTime.button_pressed: #if it's realtime
		$ScrollContainer/VBox.applydata()
