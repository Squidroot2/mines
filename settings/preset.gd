class_name Preset
extends Reference
# Docstring here


# Signals 


# Enums 


# Constants


# Exported Variables


# Variables
var name: String
var rows: int
var columns: int
var mine_count: int

# onready Variables


#  virtual methods
func _init(new_name: String, new_columns: int, new_rows: int, new_mine_count: int) -> void:
	self.name = new_name
	self.rows = new_rows
	self.columns = new_columns
	self.mine_count = new_mine_count

# public methods
func get_minefield_dimensions() -> Vector2:
	return Vector2(columns, rows)

# private methods
