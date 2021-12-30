class_name Game
extends Node
# Game node that handles win and lose conditions. Contains the Buttons for restarting and returning to the menu


# Signals 
signal game_exited()

# Enums 


# Constants


# Exported Variables

# Variables
# Static through resets and restarts
var total_mines: int
var preset_name: String

# Static after reset, modified after restart
var current_seed_name: String

# Hold either game over or win screen
var overlay: CanvasLayer

# Hold the current minefield
var minefield: Minefield = null

# Changed over course of game
var flags_remaining: int
var cells_to_reveal: int


# onready Variables
# Preloaded Resources
onready var minefield_scene : Resource = preload("res://minefield/Minefield.tscn")
onready var gameover_screen: Node = preload("res://ui/GameOver/GameOver.tscn").instance()
onready var winscreen: WinScreen = preload("res://ui/WinScreen/WinScreen.tscn").instance()

# Child References
onready var game_ui_rows: Control = get_node("MarginContainer/GameUIRows")
onready var minefield_container: Control = game_ui_rows.get_node("MinefieldContainer")
onready var game_timer: GameTimer = game_ui_rows.get_node("TopHud/TimerContainer/Timer")
onready var mine_count_label : Node = game_ui_rows.get_node("TopHud/MineCountContainer/MarginContainer/HBoxContainer/MineCountLabel")


#  virtual methods
func _ready() -> void:
	pass

# public methods
func start(minefield_dimensions: Vector2, mine_count: int, seed_name: String, new_preset_name: String) -> void:
	# Set the Labels
	_set_seed_name(seed_name)
	
	total_mines = mine_count
	_initialize_flag_count()
	
	cells_to_reveal = (minefield_dimensions.x * minefield_dimensions.y) - mine_count
	_set_preset_description(new_preset_name, minefield_dimensions, mine_count)
	_add_minefield(minefield_dimensions.x, minefield_dimensions.y, mine_count, seed_name)

# private methods
func _add_minefield(columns: int, rows: int, mine_count: int, seed_name: String) -> void:
	minefield = minefield_scene.instance()
	minefield.connect("mine_revealed", self, "_handle_mine_revealed")
	minefield.connect("cell_revealed", self, "_handle_cell_revealed")
	minefield.connect("flag_count_changed", self, "_handle_flag_count_changed")
	minefield_container.add_child(minefield)
	minefield.initialize(columns, rows, mine_count, seed_name)	

func _set_seed_name(new_seed_name: String) -> void:
	var seed_name_label: Label = game_ui_rows.get_node("GameDescriptionPanel/MarginContainer/Rows/SeedName")
	current_seed_name = new_seed_name
	seed_name_label.text = '"' + new_seed_name + '"'

func _set_preset_description(new_preset_name: String, minefield_dimensions: Vector2, mine_count: int) -> void:
	var preset_name_label: Label = game_ui_rows.get_node("GameDescriptionPanel/MarginContainer/Rows/PresetDescription")
	preset_name = new_preset_name
	preset_name_label.text = "%s (%dx%d, %d mines)" %[preset_name, minefield_dimensions.x, minefield_dimensions.y, mine_count]
	

func _initialize_flag_count() -> void:
	flags_remaining = total_mines
	mine_count_label.text = str(flags_remaining).pad_zeros(3)

# Called by both reset and restart
func _reset_game_state() -> void:
	if overlay:
		remove_child(overlay)
		overlay = null
	_initialize_flag_count()
	cells_to_reveal = (minefield.columns * minefield.rows) - total_mines
	game_timer.reset()

# signal Connections
# Handles a flag being placed or removed. Updates mine_count_label. Plays Audio
func _handle_flag_count_changed(add_flag: bool) -> void:
	$FlagAudioPlayer.play()
	if add_flag:
		flags_remaining -= 1
	else:
		flags_remaining += 1
		
	mine_count_label.text = str(flags_remaining).pad_zeros(3)

# Handles the lose condition of revealing a mine. Stops timer, shows the game over screen, plays explosion
func _handle_mine_revealed() -> void:
	game_timer.stop()
	overlay = gameover_screen
	add_child(gameover_screen)
	gameover_screen.fade_in()
	$ExplosionAudioPlayer.play()
	

func _handle_cell_revealed() -> void:
	cells_to_reveal -= 1
	$DigAudioPlayer.play()
	if cells_to_reveal == 0:
		# All cells revealed. Win the game
		overlay = winscreen
		add_child(winscreen)
		winscreen.fade_in(game_timer.get_time(), current_seed_name, preset_name, minefield.columns, minefield.rows, total_mines)
		game_timer.stop()
	
func _on_ResetButton_pressed():
	_reset_game_state()
	minefield.reset()

func _on_RestartButton_pressed():
	_reset_game_state()
	_set_seed_name(GlobalHelpers.generate_random_string(20,1))
	var old_minefield = minefield
	_add_minefield(minefield.columns, minefield.rows, total_mines, current_seed_name)
	old_minefield.queue_free()
	
func _on_MenuButton_pressed():
	# Main Node handles exiting the game and bringing back the main menu
	emit_signal("game_exited")
