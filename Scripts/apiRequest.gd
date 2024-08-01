extends Node2D

@export var currentNumberOfUpdates = 5

var dictionary
signal request_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	if Options.firstboot == true:# dont annoy user if they don't want to update
		Options.firstboot = false
		fetch("https://api.gamebanana.com/Core/Item/Data?itemtype=Tool&itemid=12975&fields=name,Updates().nUpdatesCount(),Updates().aGetLatestUpdates()", [], 0, "handle_response")
		await self.request_finished
		if dictionary != null:#don't crash editor if no internet is present
			print("Number of updates: ",dictionary[1])
			
			#check if current number of updates is less than the amount from the page
			var lineEdit = preload("res://LineNOTEdit.tscn")
			if int(dictionary[1]) > currentNumberOfUpdates:
				print("OLD OLD OLD OLD OLD")
				for nodes in get_tree().get_nodes_in_group("update"):
					nodes.show()
				for array in dictionary[2][0]._aChangeLog:
					var inst = lineEdit.instantiate()
					inst.text = array.text
					$"Patchnotes/VBoxContainer".add_child(inst)



func fetch(url:String ="https://www.duckduckgo.com/", headers:Array = [], method = HTTPClient.METHOD_GET,callback:String = "Ducks", body = null):
	if url == null or url == "":
		return null
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, callback))
	var req
	if body != null:
		req = http_request.request(url,headers,method,body)
	else:
		req = http_request.request(url,headers,method)
	if req != OK:
		return "error"
		
	

#fetch(url, [], 0, handle_response)

func handle_response(_result, _response_code, _headers, body):
	var test_json_conv = JSON.new()
	test_json_conv.parse(body.get_string_from_utf8())
	var response = test_json_conv.get_data()
	dictionary = response
	emit_signal("request_finished")
	
	



func _on_accept_pressed():
	OS.shell_open("https://gamebanana.com/tools/12975")


func _on_decline_pressed():
	for nodes in get_tree().get_nodes_in_group("update"):
		nodes.hide()
