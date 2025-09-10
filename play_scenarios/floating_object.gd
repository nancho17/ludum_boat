extends RigidBody3D

@export var theseus_body: PhysicsBody3D 

@onready var shower: MeshInstance3D = $Shower
@onready var pin_joint_3d: PinJoint3D = $PinJoint3D

var water: MeshInstance3D 

var body_volume : float = 40.0
var submerged : bool = false
var engine_gravity :float

var water_drag_angular : float = 0.1
var water_horizontal_damping: float = 0.85
var water_vertical_damping: float = 0.5


func _ready() -> void:
	engine_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	pin_joint_3d.set_node_b(theseus_body.get_path())


func _physics_process(delta: float) -> void:
	var depth = water.get_height(global_position) - global_position.y
	submerged = depth>0
	shower.visible = submerged 
	if submerged:
		#var force_uper = Vector3.UP*body_volume*engine_gravity*depth
		#apply_central_force(force_uper)
		depth+=2.0
		apply_central_force(Vector3.UP*body_volume*engine_gravity*depth)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if submerged:
		# Method 2: Enhanced velocity-based damping
		var horizontal_vel = Vector3(state.linear_velocity.x, 0, state.linear_velocity.z)
		var vertical_vel = Vector3(0, state.linear_velocity.y, 0)
		
		# Apply different damping to horizontal vs vertical movement
		horizontal_vel *= (1.0 - water_horizontal_damping)
		vertical_vel *= (1.0 - water_vertical_damping)  # Usually less damping vertically

		state.linear_velocity =(vertical_vel+horizontal_vel) #* state.step
		state.angular_velocity *= (1.0-water_drag_angular) #* state.step
