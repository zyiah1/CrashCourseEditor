extends Sprite2D
class_name Rotate

var loading = false

func _ready():
	$Spin.loading = loading

func EXPORT():
	if visible:
		$Spin.EXPORT()

func newseg():
	$Spin.newseg()

func done():
	$Spin.done()

func reposition():
	$Spin.reposition()
