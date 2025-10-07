extends Node3D

@export var basket_pupet: RigidBody3D
@export var target_score: Marker3D

@onready var character: CharacterBody3D = $Character
@onready var right_holder: Marker3D = $Character/Head2/RightHolder
@onready var right_mesh: MeshInstance3D = $Character/Head2/RightHolder/RightMesh
@onready var left_holder: Marker3D = $Character/Head2/LeftHolder
@onready var left_mesh: MeshInstance3D = $Character/Head2/LeftHolder/LeftMesh

const FLOOR_COLL_LAYER = 0b0001
const INV_GRAV = 0.1020408163265306122

var char_weight : float= 80.0805
var joint: Generic6DOFJoint3D
var superficial_body :RigidBody3D

var left_hand_grabbed : bool = false
var left_mesh_material :StandardMaterial3D

func _ready() -> void:
	print("jump vel: ",character.jump_velocity," char w",char_weight)
	left_mesh_material = left_mesh.get_active_material(0)
	#.body_entered.connect(_on_body_entered)
	#area_3d.body_exited.connect(_on_body_exited)

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

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action_1"):
		_super_automated_launch()

	if event.is_action_pressed("action_2"):
		_grab_ball()

func _super_automated_launch():
	if basket_pupet.is_linked:
		print("super_automated_launch")
		left_mesh_material.albedo_color = Color.YELLOW_GREEN
		basket_pupet.apply_launch_to(left_holder.global_position ,target_score.global_position)

func _grab_ball():
	if basket_pupet.is_linked:
		print("grab")
		basket_pupet.released()
		left_mesh_material.albedo_color = Color.YELLOW_GREEN
	else:
		print("release")
		basket_pupet.dominated()
		left_mesh_material.albedo_color = Color.BLUE

	left_hand_grabbed = basket_pupet.is_linked
		
