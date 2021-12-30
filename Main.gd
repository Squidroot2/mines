# class_name Main
extends Node
# Docstring here


# Signals 


# Enums 


# Constants


# Exported Variables


# Variables
var current_game : Game
var settings: Settings

# onready Variables
onready var game_scene : Resource = preload("res://game/Game.tscn")
onready var Settings : Resource = preload("res://settings/settings.gd")
onready var entry_point: Control = get_node("BackGround/CenterContainer")
onready var main_menu : PanelContainer  = entry_point.get_node("MainMenu")


#  virtual methods
func _ready() -> void:
	settings = Settings.new()
	main_menu.connect("open_game", self, "_new_game")
	main_menu.link_settings(settings)
	
# public methods


# private methods
func _new_game() -> void:
	entry_point.remove_child(main_menu)
	current_game = game_scene.instance()
	entry_point.add_child(current_game)
	current_game.connect("game_exited", self, "_back_to_menu")
	current_game.start(settings.get_minefield_dimensions(), settings.get_mine_count(), settings.seed_name, settings.get_preset_name())

func _back_to_menu() -> void:
	current_game.queue_free()
	entry_point.add_child(main_menu)
