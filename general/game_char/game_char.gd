extends Node3D

@onready var character: CharacterBody3D = $Character
@onready var area_3d: Area3D = $Character/AreaWeight

const FLOOR_COLL_LAYER = 0b0001
const INV_GRAV = 0.1020408163265306122

var char_weight : float= 80.0805
var joint: Generic6DOFJoint3D
var superficial_body :RigidBody3D

func _ready() -> void:
	print("jump vel: ",character.jump_velocity," char w",char_weight)
	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)

func get_player_camera()->Camera3D:
	return character.CAMERA

func _on_body_exited(body: Node3D):
	superficial_body=null

func _on_body_entered(body: Node3D):
	if body is RigidBody3D:
		superficial_body= body

func _physics_process(delta):
		if superficial_body != null:
			superficial_body.apply_force(Vector3.DOWN * char_weight*9.8,character.global_position)
			#print(superficial_body.name," to ",Vector3.DOWN * char_weight," whe: " , character.global_position)
