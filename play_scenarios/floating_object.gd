extends RigidBody3D

@export var water_drag : float = 0.05
@export var water_drag_angular : float = 0.05
var water: MeshInstance3D 
@export var theseus_body: PhysicsBody3D 
@onready var pin_joint_3d: PinJoint3D = $PinJoint3D

var body_volume : float = 10.0
var submerged : bool = false
var engine_gravity :float

signal self_contained_signal_w

func _ready() -> void:
	engine_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	pin_joint_3d.set_node_b(theseus_body.get_path())
	await self_contained_signal_w

func _physics_process(delta: float) -> void:
	var depth = water.get_height(global_position) - global_position.y 
	submerged = depth>0
	if submerged:
		apply_central_force(Vector3.UP*body_volume*engine_gravity*depth)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if submerged:
		state.linear_velocity *= (1.0-water_drag)  
		state.angular_velocity *= (1.0-water_drag_angular)  
	
