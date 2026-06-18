extends Node2D

func _ready():
	$Strikes.text = "Strikes: %d" % Gamedata.strikes
	$Score.text = "Score: %d" % Gamedata.score

func _on_retry_pressed():
	get_tree().change_scene_to_file("res://scenes/1dash1.tscn")

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main menu.tscn")
