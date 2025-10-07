extends RigidBody3D

@export var to_follow: Node3D
@export var to_rotate_order: Node3D
@export var follow_method: FollowMethod = FollowMethod.FORCE_BASED
@export var arrival_distance: float = 1.0

# Method 1: Force-based following (more realistic physics)
@export_group("Force Based")
@export var follow_force: float = 1000.0
@export var max_follow_force: float = 5000.0
@export var damping_factor: float = 0.8

# Method 2: Velocity-based following (more direct control)
@export_group("Velocity Based")
@export var follow_speed: float = 10.0
@export var velocity_smoothing: float = 0.1

var colide_activation : bool = false

var is_linked : bool = false
var impulse_go : Array[Vector3]
var proyectiles_init_pos : Vector3 = Vector3.ZERO

var bullet_speed = 5.0
var proyectiles_init_v : Vector3 = 15.0 * Vector3.UP

enum FollowMethod {
	FORCE_BASED,
	VELOCITY_BASED
}
func _ready() -> void:
	body_entered.connect(collided_to_thing)

func collided_to_thing(body:Node) -> void:
	if colide_activation:
		colide_activation = false
		print("collition",colide_activation,body)
		set_linear_damp_mode(RigidBody3D.DAMP_MODE_COMBINE)

func dominated() -> void:
	print("dominated",is_linked)
	is_linked = true

func released() -> void:
	print("released",is_linked)
	is_linked = false

func apply_launch_to(this_pos : Vector3,obj_pos : Vector3):
	proyectiles_init_pos = this_pos
	impulse_go.append(obj_pos)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not impulse_go.is_empty():
		is_linked = false
		#print(state.get_constant_force(),state.get_total_gravity(),state.get_linear_velocity  ())
		physic_execute(state,impulse_go.pop_back())
		impulse_go.clear()
		return
		#gpu_particles_3d_2.set_emitting(true)

	if not to_follow:
		return

	if not is_linked :
		return

	match follow_method:
		FollowMethod.FORCE_BASED:
			_apply_follow_force(state)
			_slow_angular_velocity(state)
			#_apply_look_at_angular_velocity(state)
		FollowMethod.VELOCITY_BASED:
			_apply_follow_velocity(state)
			_apply_look_at_angular_velocity(state)

# Method 1: Force-based approach (recommended for realistic physics)
func _apply_follow_force(state: PhysicsDirectBodyState3D) -> void:
	var direction = to_follow.global_position - global_position
	var distance = direction.length()
	
	direction = direction.normalized()
		
	# Calculate desired force based on distance
	var desired_force = direction * follow_force * distance  * distance
		
	# Add velocity-based damping to prevent overshooting
	var velocity_correction = -state.linear_velocity * damping_factor * 16
	var total_force = desired_force + velocity_correction
		
		# Clamp force to prevent unrealistic acceleration
	if total_force.length() > max_follow_force:
		total_force = total_force.normalized() * max_follow_force
	
	state.apply_central_force(total_force)

# Method 2: Velocity-based approach (more predictable but less realistic)
func _apply_follow_velocity(state: PhysicsDirectBodyState3D) -> void:
	var direction = to_follow.global_position - global_position
	var distance = direction.length()
	var current_velocity:Vector3 = state.linear_velocity
	var calc_velocity = Vector3.ZERO
	calc_velocity = direction.normalized() * distance  * follow_speed
	state.linear_velocity = current_velocity.lerp(calc_velocity, velocity_smoothing)

# Alternative: Hybrid approach combining both methods
func _apply_hybrid_follow(state: PhysicsDirectBodyState3D) -> void:
	var direction = to_follow.global_position - global_position
	var distance = direction.length()
	
	if distance > arrival_distance * 2:
		# Use force-based when far away for realistic physics
		_apply_follow_force(state)
	elif distance > arrival_distance:
		# Use velocity-based when close for precise control
		_apply_follow_velocity(state)
	else:
		# Stop smoothly when very close
		state.linear_velocity *= 0.45

# Optional: Add rotation to face the target
func _slow_angular_velocity(state: PhysicsDirectBodyState3D) -> void:
	if not to_rotate_order:
		return
	state.angular_velocity *= 0.85

func _apply_look_at_angular_velocity(state: PhysicsDirectBodyState3D) -> void:
	if not to_rotate_order:
		return
	
	var target_rotation = to_rotate_order.rotation.y
	var current_rotation = rotation.y
	var angle_diff = wrapf(target_rotation - current_rotation, -PI, PI)
	
	# 0.01111* TAU = 1°
	if abs(angle_diff) > TAU * 0.011111111:
		var desired_angular_velocity = angle_diff * 15.0  # Adjust multiplier as needed
		var current_angular_velocity = state.angular_velocity.y
		
		# Calculate the difference and apply it
		var velocity_correction = desired_angular_velocity - current_angular_velocity
		var damping_factor_angular = 0.36  # Adjust to prevent overshooting
		
		# Apply angular velocity directly

		state.angular_velocity.y += velocity_correction * damping_factor_angular
		print("E: ", angle_diff, " desired_vel: ", desired_angular_velocity, " current_vel: ", current_angular_velocity)
	else:
		state.angular_velocity.y *= 0.45
		
		
	#set_global_position(proyectiles_init_pos)
	#bullet_collider.set_disabled.call_deferred(false)

func physic_execute(state:PhysicsDirectBodyState3D, obj_position : Vector3):
	set_linear_damp_mode(RigidBody3D.DAMP_MODE_REPLACE)
	colide_activation = true
	#global_transform = global_transform.looking_at(Vector3(obj_position.x, get_global_position().y, obj_position.z))
	#set_global_position(proyectiles_init_pos)
	global_transform = global_transform.looking_at(obj_position)
	transform= transform.rotated_local(Vector3(1,0, 0), -PI/2)
	set_visible(true)

	var dir_vec = (obj_position - get_global_position())
	var an_angle:float = -atan(dir_vec.z/dir_vec.x)
	#var offset := Vector3(0.0,0.0,0.0)
	#dir_vec +=offset
	
	var gravity_v := Vector3(0.0,-9.8,0.0)
	var f_time = dir_vec.length() / bullet_speed
	var vel_f : Vector3  =  (dir_vec/ f_time) - (gravity_v * f_time * 0.5) # -(gravity_v * state.get_step())
	var moment = get_mass() * vel_f 
	var initial_vel = proyectiles_init_v-state.get_linear_velocity()

	state.set_linear_velocity(vel_f)
	state.integrate_forces()
