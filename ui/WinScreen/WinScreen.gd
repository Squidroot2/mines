class_name WinScreen
extends CanvasLayer

func fade_in(time: float, seed_name: String, preset_name: String, minefield_columns: int, minefield_rows: int, mine_number: int):
	var win_screen_rows: VBoxContainer = get_node("PanelContainer/MarginContainer/VBoxContainer")
	var score_label: Label = win_screen_rows.get_node("ScoreLabel")
	var seed_label: Label = win_screen_rows.get_node("SeedLabel")
	var preset_label: Label = win_screen_rows.get_node("PresetLabel")
	
	score_label.text = "Time: %f" % time
	seed_label.text = "Seed: %s" % seed_name
	preset_label.text = "Preset: %s (%dx%d, %d Mines)" %[preset_name, minefield_columns, minefield_rows, mine_number]
	$AnimationPlayer.play("fade_in")
