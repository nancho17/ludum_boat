extends Node3D

@onready var floating_bodies: Node3D = $FloatingBodies
@export var water_boat : MeshInstance3D
@onready var boat_camera: Camera3D = $Boat/BoatCamera

enum PlayBoat {SQUARE, VARIABLE,SIMPLE,FISH}
@export var boat_mesh: PlayBoat = PlayBoat.SQUARE
@onready var square: MeshInstance3D = $Boat/Square
@onready var boat_var: MeshInstance3D = $Boat/BoatVar
@onready var boat_sim: MeshInstance3D = $Boat/BoatSim
@onready var tug_boat: Node3D = $Boat/TugBoat
@onready var boat_dict :Dictionary={ 
	PlayBoat.SQUARE:square,
	PlayBoat.VARIABLE:boat_var,
	PlayBoat.SIMPLE:boat_sim,
	PlayBoat.FISH:tug_boat}

func get_ship_camera():
	return boat_camera

func _ready() -> void:
	var boat_mesh : Node3D = boat_dict[boat_mesh]
	boat_mesh.set_visible(true)

	if !water_boat.is_node_ready():
		await water_boat.ready
	
	for f_body in floating_bodies.get_children():
		f_body.water = water_boat
