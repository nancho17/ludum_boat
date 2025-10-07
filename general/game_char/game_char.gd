extends Node3D

@export var basket_pupet: RigidBody3D
@export var target_score: Marker3D
@onready var aefvt: MeshInstance3D = $Aefvt

@onready var head_2: Node3D = $Character/Head2
@onready var character: CharacterBody3D = $Character
@onready var right_holder: Marker3D = $Character/Head2/RightHolder
@onready var right_mesh: MeshInstance3D = $Character/Head2/RightHolder/RightMesh
@onready var left_holder: Marker3D = $Character/Head2/LeftHolder
@onready var left_mesh: MeshInstance3D = $Character/Head2/LeftHolder/LeftMesh
@onready var char_cam: Camera3D = $Character/Head2/CharCam

signal pressed_force(gameplay_force:float)

const FLOOR_COLL_LAYER = 0b0001
const INV_GRAV = 0.1020408163265306122
const MAX_TIME_FORCE = 3.0

var launch_gameplay_force :float= 0.0
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


func _process(delta: float) -> void:
	if Input.is_action_pressed("action_1"):
		launch_gameplay_force+=delta
		pressed_force.emit(launch_gameplay_force)

	if Input.is_action_just_released("action_1"):
		_launch_to_aim()
		launch_gameplay_force = 0.0

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
#	if event.is_action_pressed("action_1"):
#		_launch_to_aim()

	if event.is_action_pressed("action_2"):
		_grab_ball()

	if event.is_action_pressed("action_3"):
		_super_automated_launch()

func _super_automated_launch():
	if basket_pupet.is_linked:
		print("super_automated_launch")
		left_mesh_material.albedo_color = Color.YELLOW_GREEN
		basket_pupet.bullet_speed = 5.0
		basket_pupet.apply_launch_to(left_holder.global_position ,target_score.global_position)

func _launch_to_aim():
	if basket_pupet.is_linked:
		launch_gameplay_force = min(launch_gameplay_force,MAX_TIME_FORCE)
		print("_launch_to_aim")
		left_mesh_material.albedo_color = Color.YELLOW_GREEN
		var calc_vec = Vector3.FORWARD*(2.5+(6.66 * launch_gameplay_force)) 
		var position_to : Vector3 = head_2.global_transform * calc_vec

		aefvt.global_position = position_to
		basket_pupet.bullet_speed = 8.0
		basket_pupet.apply_launch_to(left_holder.global_position ,position_to)

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
		
func get_cam() -> Camera3D:
	return char_cam
