class_name Cell
extends Button
# A Cell that may or may not contain a mine. Can be clicked on to be revealed


# Signals 
signal cell_revealed(has_mine, surrounding_mines)
signal cell_flag_toggled(new_state)

# Enums 
enum CellState {
	HIDDEN,
	FLAGGED,
	REVEALED	
}

# Constants


# Exported Variables


# Variables
var surrounding_mines: int
var has_mine: bool
var current_state: int = CellState.HIDDEN

# onready Variables
var flag_icon: Resource = preload("res://cell/assets/images/flag.png")
var num_icons: Array = [
	preload("res://cell/assets/images/1.png"),
	preload("res://cell/assets/images/2.png"),
	preload("res://cell/assets/images/3.png"),
	preload("res://cell/assets/images/4.png"),
	preload("res://cell/assets/images/5.png"),
	preload("res://cell/assets/images/6.png"),
	preload("res://cell/assets/images/7.png"),
	preload("res://cell/assets/images/8.png")]

#  virtual methods
func _ready() -> void:
	_update_appearance()

# public methods
func reveal(override_flag: bool = false, silent: bool = true) -> void:
	#Override flag is used during reveal all to avoid recursive overflows and other strange behavior
	if current_state == CellState.REVEALED:
		return
	
	elif override_flag:
		_change_state(CellState.REVEALED)

	elif current_state == CellState.HIDDEN:
		_change_state(CellState.REVEALED)
		emit_signal('cell_revealed', has_mine, surrounding_mines)
		add_stylebox_override("focus", get_stylebox("disabled_focus"))
	
	if not silent:
		if has_mine:
			pass
			#$ExplosionAudioPlayer.play()
		else:
			pass
			#$DigAudioPlayer.play()
		
		
func toggle_flag() -> void:	
	match current_state:
		CellState.HIDDEN:
			_change_state(CellState.FLAGGED)
			emit_signal("cell_flag_toggled", true)
		CellState.FLAGGED:
			_change_state(CellState.HIDDEN)
			emit_signal("cell_flag_toggled", false)
		CellState.REVEALED:
			print("%s: toggle_flag() called but cell already revealed. No action taken" %self)

func reset() -> void:
	pressed = false
	_change_state(CellState.HIDDEN)

# private methods
func _change_state(new_state: int) -> void:
	current_state = new_state
	_update_appearance()

func _update_appearance() -> void:	
	match current_state:
		CellState.HIDDEN:
			disabled = false
			icon = null
			
		CellState.FLAGGED:
			icon = flag_icon
			
		CellState.REVEALED:
			disabled = true
			if has_mine:
				text = "X"
				icon = null
			elif surrounding_mines > 0:
				icon = num_icons[surrounding_mines-1]	
			

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("flag"):
		toggle_flag()

func _on_Cell_pressed():
	reveal(false,false)
