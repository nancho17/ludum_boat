extends Node3D

@onready var camera_3d_2: Camera3D = $Camera3D2
@onready var camera_3d_3: Camera3D = $Camera3D3
@onready var camera_3d_4: Camera3D = $Camera3D4
@onready var camera_3d_5: Camera3D = $Camera3D5

var cameras :Array
var cameras_qty : int
var current_int : int = 0

var flag_tool : bool = false


func _ready() -> void:
	cameras = [
		camera_3d_2,
		camera_3d_5,
		camera_3d_4,
		camera_3d_3,
		]
	cameras_qty=cameras.size()
	camera_3d_2.current = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_change"):
		current_int =posmod(current_int+1,cameras_qty)
		cameras[current_int].current = true
