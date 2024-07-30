extends OptionButton

var custom

func _ready():
	add_item("green")
	add_item("red")
	add_item("blue")
	add_item("yellow")
	add_item("orange")
	add_item("purple")
	add_item("pink")
	add_item("black")
	
	match Options.colorbg:
		"0.3,0.6,0.3":
			select(0)
		"0.9,0.1,0.2":
			select(1)
		"0.1,0.4,0.7":
			select(2)
		"0.7,0.8,0.1":
			select(3)
		"1.0,0.6,0.1":
			select(4)
		"0.3,0.2,0.6":
			select(5)
		"0.8,0.3,0.9":
			select(6)
		"0.1,0.1,0.1":
			select(7)
		
	





func _on_setting2_item_selected(index):
	$custom/ColorPicker.hide()
	$custom.custom = false
	match selected:
		0:
			Options.colorbg = "0.3,0.6,0.3"
		1:
			Options.colorbg = "0.9,0.1,0.2"
		2:
			Options.colorbg = "0.1,0.4,0.7"
		3:
			Options.colorbg = "0.7,0.8,0.1"
		4:
			Options.colorbg = "1.0,0.6,0.1"
		5:
			Options.colorbg = "0.3,0.2,0.6"
		6:
			Options.colorbg = "0.8,0.3,0.9"
		7:
			Options.colorbg = "0.1,0.1,0.1"
		

