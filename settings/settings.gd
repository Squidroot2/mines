class_name Settings
extends Reference
# Docstring here


# Signals 


# Enums 
enum PRESETS {
	EASY
	MEDIUM
	HARD
	EPIC
	CUSTOM
}

# Constants

# Exported Variables


# Variables
var _current_preset: int 
var seed_name: String
var presets: Array

#  virtual methods
func _init(new_seed_name = "mines", current_preset = PRESETS.EASY)  -> void:
	presets = [	Preset.new("EASY",9,9,10),
				Preset.new("MEDIUM",16,16,40),
				Preset.new("HARD",30,16,99),
				Preset.new("EPIC",52,24,365),
				Preset.new("CUSTOM",42,20,99)] 
	self._current_preset = current_preset
	self.seed_name = new_seed_name

# public methods
func get_minefield_dimensions() -> Vector2:
	return presets[_current_preset].get_minefield_dimensions()

func get_mine_count() -> int:
	return presets[_current_preset].mine_count

func change_preset(new_preset_index : int) -> void:
	assert(-1 < new_preset_index and new_preset_index < presets.size())
	_current_preset = new_preset_index

func set_custom_preset(columns: int, rows: int, mine_count: int) -> void:
	set_custom_columns(columns)
	set_custom_rows(rows)
	set_custom_mines(mine_count)
	
func set_custom_columns(columns: int) -> void:
	presets[PRESETS.CUSTOM].columns = columns
	
func set_custom_rows(rows: int) -> void:
	presets[PRESETS.CUSTOM].rows = rows

func set_custom_mines(mine_count: int) -> void:
	presets[PRESETS.CUSTOM].mine_count = mine_count

func get_preset_name() -> String:
	return presets[_current_preset].name

# private methods
