# class_name <class_name>
extends PanelContainer
# Docstring here


# Signals 
signal open_game

# Enums 


# Constants


# Exported Variables


# Variables
var settings: Settings

# onready Variables
onready var menu_rows: VBoxContainer = get_node("MarginContainer/MenuRows")	
onready var x_label: LineEdit = menu_rows.get_node("DimensionRow/WidthVBox/WidthValue")
onready var y_label: LineEdit = menu_rows.get_node("DimensionRow/HeightVbox/HeightValue")
onready var mine_count_label: LineEdit = menu_rows.get_node("MineRow/MineCount")
onready var start_button: Button = menu_rows.get_node("StartButton")
onready var seed_name_label: LineEdit = menu_rows.get_node("Seedname")

#  virtual methods
func _ready() -> void:
	randomize() # Randomizes the seed generator

# public methods
func link_settings(new_settings: Settings) -> void:
	settings = new_settings
	
	# Gets references to nodes used in the function
	var button_row: HBoxContainer = menu_rows.get_node("ButtonRow")
	
	# Populate Buttons
	for index in range(settings.presets.size()):
		# Add Button with Preset Label
		var preset = settings.presets[index]
		var button = Button.new()
		button_row.add_child(button)
		button.text = preset.name
		button.connect("button_down", self, "_on_Preset_Button_Pressed", [index])
	
	_reflect_new_preset()
	
	# Set Seed Name
	seed_name_label.text = str(settings.seed_name)

# private methods
# Disables the start button if the settings are not valid. Enables them is they are
func _check_settings_valid_for_start() -> void:
	var disable_start: = false
	var dimensions: Vector2 = settings.get_minefield_dimensions()
	
	if dimensions.y < 2:
		disable_start = true
	elif dimensions.x < 2:
		disable_start = true
	
	start_button.disabled = disable_start

func set_custom_settings_lock(locked: bool) -> void:
	x_label.editable = !locked
	y_label.editable = !locked
	mine_count_label.editable = !locked	


func _reflect_new_preset() -> void:
	# Set Dimesions Labels
	var dimensions: Vector2 = settings.get_minefield_dimensions()
	x_label.text = str(dimensions.x)
	y_label.text = str(dimensions.y)
	
	# Set MineCount Label
	mine_count_label.text = str(settings.get_mine_count())

# The X, Y, and Mines must be integer string. Returns the new integer or -1 is invalid
func _check_string_is_valid_int(test_string: String) -> int:
	if test_string.empty():
		return 0
	else:
		var converted_int = int(test_string)
		if converted_int < 0:
			return -1
		elif str(converted_int) == test_string:
			return converted_int
		else:
			return -1

# Signals
func _on_StartButton_pressed() -> void:
	emit_signal("open_game")

func _on_Seedname_text_changed(new_text):
	settings.seed_name = new_text

func _on_Preset_Button_Pressed(preset_index: int) -> void:
	settings.change_preset(preset_index)
	_reflect_new_preset()
	
	if preset_index == Settings.PRESETS.CUSTOM:
		set_custom_settings_lock(false)
	else:
		set_custom_settings_lock(true)
	
	_check_settings_valid_for_start()

func _on_MineCount_text_changed(new_text):
	var input_as_int: int = _check_string_is_valid_int(new_text)
	if input_as_int == -1:
		mine_count_label.text = str(settings.get_mine_count())
	else:
		settings.set_custom_mines(input_as_int)
	
	_check_settings_valid_for_start()

func _on_WidthValue_text_changed(new_text):
	var input_as_int: int = _check_string_is_valid_int(new_text)
	if input_as_int == -1:
		x_label.text = str(settings.get_minefield_dimensions().x)
	else:
		settings.set_custom_columns(input_as_int)
	
	_check_settings_valid_for_start()

func _on_HeightValue_text_changed(new_text):
	var input_as_int: int = _check_string_is_valid_int(new_text)
	if input_as_int == -1:
		y_label.text = str(settings.get_minefield_dimensions().y)
	else:
		settings.set_custom_rows(input_as_int)
	
	_check_settings_valid_for_start()

func _on_GenerateSeedButton_pressed():	
	# Initialize a new sting to hold the random string
	var rand_string: String = GlobalHelpers.generate_random_string(20,1)
	# Replace the text with the new string
	seed_name_label.text = rand_string
	_on_Seedname_text_changed(rand_string)
