extends Panel

@export var input: InputEventAction
var default_mapping: InputEvent
var mapping: InputEvent

@export var text_overide: String

func _ready():
	if input == null:
		return
	$Name.text = input.action.capitalize()
	if text_overide:
		$Name.text = text_overide
	default_mapping = InputMap.action_get_events(input.action)[0]
	mapping = default_mapping
	$Keybind.text = InputMap.action_get_events(input.action)[0].as_text()
	
