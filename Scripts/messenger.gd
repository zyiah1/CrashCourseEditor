extends Sprite2D

var loading = false


func _ready():
	$Spin.loading = loading

func EXPORT():
	$Spin.EXPORT()

func newseg():
	$Spin.newseg()

func done():
	$Spin.done()

func reposition():
	$Spin.reposition()
