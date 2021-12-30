class_name GameTimer
extends Label


const MAX_DISPLAYED = 60*100
var count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func get_time() -> float:
	return float(count) + (1- $SecondAdd.time_left)

func reset() -> void:
	count = 0
	_update_text()
	$SecondAdd.start()

func stop() -> void:
	$SecondAdd.stop()

func _update_text() -> void:
	if count < MAX_DISPLAYED:
		text = "%s:%s" %[str(count/60).pad_zeros(2), str(count % 60).pad_zeros(2)]
	

func _on_SecondAdd_timeout() -> void:
	# Add a second
	count += 1
	_update_text()

