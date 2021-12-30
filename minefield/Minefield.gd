class_name Minefield
extends GridContainer
# Docstring here


# Signals 
signal mine_revealed()
signal cell_revealed()
signal flag_count_changed()

# Enums 


# Constants


# Exported Variables

# Variables
var rows: int
var rng: RandomNumberGenerator
var revealed_cell: Cell # Used for resets
var num_mines: int
var cells: Array

# onready Variables
#onready var grid_container : GridContainer = $GridContainer
onready var cell_scene : Resource = preload('res://cell/Cell.tscn')

#  virtual methods
func _ready() -> void:
	rng = RandomNumberGenerator.new()

# Public Functions
func reset() -> void:
	for cell in get_children():
		cell.reset()
	
	revealed_cell.reveal()

func initialize(new_columns: int, new_rows: int, new_num_mines: int, seed_name: String) -> void:
	rows = new_rows
	columns = new_columns
	num_mines = new_num_mines
	rng.seed = GlobalHelpers.string_to_seed(seed_name)

	_generate_minefield()
	
# public methods
func get_cell_at_location(x: int, y: int) -> Node:
	if x < 0 or x >= columns:
		return null
	if y < 0 or y >= rows:
		return null
	
	var index: int = x + (y*columns)
	return cells[index]

func reveal_all() -> void:
	for cell in cells:
		cell.reveal(true)

# Private Functions
func _generate_minefield() -> void:
		# Populate minefield with cells
	_generate_cells()
	
	cells = get_children()
	
	# Place Mines
	var mines_placed = 0
	var cell_index = 0
	#var cells: Array = get_children()
	
	var chance_for_mine: float = float(num_mines) / cells.size()
	while mines_placed < num_mines:
		var roll = rng.randf()
		if roll <= chance_for_mine and not cells[cell_index].has_mine:
			cells[cell_index].has_mine = true
			mines_placed += 1
		
		cell_index += 1
		
		# If at the end of the array, go back to the beginning
		if cell_index == cells.size():
			cell_index = 0
	
	# Determine Cell Values
	for y in range(rows):
		for x in range(self.columns):
			var current_cell: Cell = get_cell_at_location(x,y)
			for rel_x in range(-1,2):
				for rel_y in range(-1,2):
					if rel_x == 0 and rel_y ==0:
						continue					
					var neighbor: Cell = get_cell_at_location(x+rel_x, y+rel_y)
					if neighbor:
						if neighbor.has_mine:
							current_cell.surrounding_mines += 1
	
	# Determine Cells that are safe to reveal
	var neighborless_cells : Array  = []# neighborless = no neighbors and doesn't have mine
	var mineless_cells : Array = []
	
	for cell in cells:
		if not cell.has_mine:
			mineless_cells.append(cell)
			if cell.surrounding_mines == 0:
				neighborless_cells.append(cell)
	
	# So long as there are neighborless cells, prefer those
	if neighborless_cells:
		var rand_index: int = rng.randi_range(0, neighborless_cells.size()-1)
		revealed_cell = neighborless_cells[rand_index]
	else:
		var rand_index: int = rng.randi_range(0, mineless_cells.size()-1)
		revealed_cell =	mineless_cells[rand_index]
	
	revealed_cell.reveal()

# Called by generate minefield
func _generate_cells() -> void:
	var cell_count = rows * columns
	for i in range(cell_count):
		var new_cell = cell_scene.instance()
		add_child(new_cell)
		new_cell.connect("cell_revealed", self, 'handle_cell_revealed', [i])
		new_cell.connect("cell_flag_toggled", self, '_relay_flag_count_change')

# Connected to Cell signal via Minefield Factory
# Signals
func handle_cell_revealed(cell_has_mine: bool, cell_surrounding_mines_count: int, cell_index: int) -> void:
	if cell_has_mine:
		reveal_all()
		emit_signal("mine_revealed")
	else:
		emit_signal("cell_revealed")
		if cell_surrounding_mines_count == 0:
			
			# Identify special cases
			var surrounding_relative_locations: Array = [
				-columns-1,	# Top Left
				-columns, 	# Top
				-columns+1, # Top Right
				-1, 		# Left
				1, 			# Right
				columns-1,	# Bottom Left
				columns,	# Bottom
				columns+1	# Bottom Right
			]
			
			var cell_column: int = cell_index % columns
			
			for location in surrounding_relative_locations:
				var neighbor_index = cell_index + location
				if neighbor_index < get_child_count() and neighbor_index >= 0:
					var neighbor_column = neighbor_index % columns
					if (cell_column == 0 and neighbor_column == columns-1):
						continue
					elif (cell_column == columns-1 and neighbor_column == 0):
						continue
					get_children()[neighbor_index].reveal(false)

func _relay_flag_count_change(add_flag: bool) -> void:
	emit_signal("flag_count_changed", add_flag)


