extends RichTextLabel

func _ready():
	updateDisplay()
	Stats.crumbs_updated.connect(updateDisplay)
	


func _on_remove_pressed() -> void:
	Stats.remove_crumbs(50)


func _on_add_pressed() -> void:
	Stats.add_crumbs(50)


func updateDisplay():
	text = str(Stats.get_crumbs())
