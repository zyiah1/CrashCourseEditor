extends Panel

@export var input: InputEventAction
@export var default_mapping: InputEvent
var mapping: InputEvent

@export var text_overide: String

var listening = false

func _ready():
	if input == null:
		return
	$Name.text = input.action.capitalize()
	if text_overide:
		$Name.text = text_overide
	#default_mapping = InputMap.action_get_events(input.action)[0]
	mapping = InputMap.action_get_events(input.action)[0]
	$Keybind.text = InputMap.action_get_events(input.action)[0].as_text()
	


func _on_keybind_pressed():
	listening = true


func _on_reset_button_down():
	print("RESET")
	InputMap.action_erase_events(input.action)
	InputMap.action_add_event(input.action, default_mapping)
	$Keybind.text = InputMap.action_get_events(input.action)[0].as_text()


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		return
	if event.pressed and listening:
		InputMap.action_erase_events(input.action)
		InputMap.action_add_event(input.action, event)
		listening = false
		$Keybind.text = InputMap.action_get_events(input.action)[0].as_text()
