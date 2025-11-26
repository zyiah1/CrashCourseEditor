extends Node2D

func _ready():
	for node in get_tree().get_nodes_in_group("MenuButton"):
		node.connect("about_to_popup",Callable(self,"menubutton_popup").bind(node.get_popup()))
		node.get_popup().connect("id_pressed",Callable(self,"menubutton_selection").bind(node.get_popup()))
		node.get_popup().hide_on_checkable_item_selection = false

func menubutton_popup(popup:PopupMenu):
	popup.scroll_to_item(0)
	if Input.is_action_pressed("bridge"):
		popup.scroll_to_item(30)
	var already_selected_ids = []
	for menubutton in get_tree().get_nodes_in_group("MenuButton"):
		already_selected_ids.append_array(menubutton.id_order)
	
	for index in range(popup.item_count):
		popup.set_item_disabled(index,false)
		popup.set_item_icon_max_width(index,80)
	
	for id in already_selected_ids:
		var index = popup.get_item_index(id)
		if not popup.is_item_checked(index):
			popup.set_item_disabled(index,true)
			popup.set_item_icon_max_width(index,30)
	
	

func menubutton_selection(id:int,popup:PopupMenu):
	var button = popup.get_parent()
	var popup_index = popup.get_item_index(id)
	if id == 0: #NONE WAS SELECTED
		for index in range(popup.item_count):
			popup.set_item_checked(index,false)
		button.icon = preload("uid://bqs6ievnnk2g1") #none.png
		button.id_order.clear()
		return
	
	
	#toggle the item's check
	popup.set_item_checked(popup_index, not popup.is_item_checked(popup_index))
	
	if popup.is_item_checked(popup_index):
		button.id_order.append(id)
		if button.icon == preload("uid://bqs6ievnnk2g1"): #if it's checked and none, then its the new icon
			button.icon = popup.get_item_icon(popup_index)
	
	if not popup.is_item_checked(popup_index): #set the icon to none/the first possible icon
		button.id_order.erase(id)
		button.icon = preload("uid://bqs6ievnnk2g1") #none.png
		if button.id_order.size() != 0:
			button.icon = popup.get_item_icon(popup.get_item_index(button.id_order[0]))
