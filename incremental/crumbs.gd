extends RichTextLabel

func _ready():
	updateDisplay(Stats.get_crumbs())
	Stats.crumbs_updated.connect(updateDisplay)
	


func _on_remove_pressed() -> void:
	Stats.remove_crumbs(50)


func _on_add_pressed() -> void:
	Stats.add_crumbs(50)


func updateDisplay(crumbs):
	text = str(crumbs)
