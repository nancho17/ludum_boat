extends Node3D

@onready var camera_3d_2: Camera3D = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SubViewportContainer/SubViewport/Camera3D2
@onready var camera_3d_3: Camera3D = $Camera3D3
@onready var camera_3d_4: Camera3D = $Camera3D4
@onready var camera_3d_5: Camera3D = $Camera3D5

@onready var character: CharacterBody3D = $game_char/Character
@onready var score_area: Area3D = $ScoreArea

@onready var label_points_a: Label = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/LabelPointsA
@onready var label_points_b: Label = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/LabelPointsB

var cameras :Array
var cameras_qty : int
var current_int : int = 0
var flag_tool : bool = false

var player_a_score : int = 0
var player_b_score : int = 0


func _ready() -> void:
	cameras = [
		character.CAMERA,
		camera_3d_2,
		camera_3d_5,
		camera_3d_4,
		camera_3d_3,

		]
	cameras_qty=cameras.size()
	score_area.point_from_player.connect(player_score)
	set_gui()

func player_score(data: int) -> void:
	print("someone score ",data )
	if randi()%10 < 5:
		player_a_score+=data 
	else:
		player_b_score+=data 
	set_gui()

func set_gui():
	label_points_a.text=String.num(player_a_score)
	label_points_b.text=String.num(player_b_score)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_change"):
		current_int =posmod(current_int+1,cameras_qty)
		cameras[current_int].current = true
