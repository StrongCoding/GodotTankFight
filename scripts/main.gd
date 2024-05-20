extends Control

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_play_button_button_down():
	get_tree().change_scene_to_file("res://scenes/map.tscn")
