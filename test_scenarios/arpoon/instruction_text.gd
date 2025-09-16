extends MeshInstance3D

@export var rotation_speed: float = 2.0   # how fast it swings
@export var rotation_amount: float = 0.5 # max angle in radians

var time_passed: float = 0.0

func _process(delta: float) -> void:
	time_passed += delta * rotation_speed
	# Rotate back and forth around Y axis
	rotation.y = sin(time_passed) * rotation_amount
