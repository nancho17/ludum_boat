extends Node3D
@export_group("First Body Data")
@export var first_link: Marker3D
@export var first_body: PhysicsBody3D

@export_group("Last Body Data")
@export var last_link: Marker3D
@export var last_body: PhysicsBody3D

@export_group("Cuerda Params")
@export var chained_links_count: int = 10

@onready var link_point: RigidBody3D = $LinkPoint
@onready var path_3d: Path3D = $Path3D
@onready var pin_joint_3d: PinJoint3D = $PinJoint3D

const LINK_POINT = preload("res://general/cuerda/link_point.tscn")

var link_height :float = .15
var link_array :Array=[] 
var initial_dir_vec : Vector3 = Vector3.DOWN

func _ready() -> void:
	link_array = []
	if first_link!=null and last_link!=null:
		initial_dir_vec = (last_link.global_position-first_link.global_position).normalized()
	
	if first_link!=null and first_body!=null:


		link_point.global_position= first_link.global_position+(initial_dir_vec*link_height/2)
		var first_point =  PinJoint3D.new()
		add_child(first_point)
		#first_point.exclude_nodes_from_collision = false
		#first_point.set_param(PinJoint3D.PARAM_BIAS,0.01) 
		first_point.global_position = first_link.global_position
		first_point.node_a = first_body.get_path()
		first_point.node_b = link_point.get_path()
		link_array.append(first_point)


	cuerda_generation()


	if last_link!=null and last_body!=null:
		link_array.back().global_position= last_link.global_position+(initial_dir_vec*link_height/2)

		var last_point =  PinJoint3D.new()
		add_child(last_point)
		last_point.global_position = last_link.global_position
		last_point.node_a = link_array.back().get_path()
		last_point.node_b = last_body.get_path()
		link_array.append(last_point)

func cuerda_generation() -> void:
	var base_link =  link_point
	link_array.append(base_link) 
	path_3d.curve.add_point(base_link.position)
	for n in range(chained_links_count):
		var base_point =  PinJoint3D.new()
		add_child(base_point)
		base_point.solver_priority=n+1
		#base_point.set_param(PinJoint3D.PARAM_BIAS,0.1) 
		#base_point.set_param(PinJoint3D.PARAM_DAMPING,2.0) 
		#base_point.set_param(PinJoint3D.PARAM_IMPULSE_CLAMP,0.0) 

		base_point.position= base_link.position+(initial_dir_vec*link_height/2)
		base_point.node_a = base_link.get_path()
		var link_point_n: RigidBody3D = LINK_POINT.instantiate()
		add_child(link_point_n)
		link_point_n.transform = base_link.transform.orthonormalized()
		link_point_n.position += initial_dir_vec*link_height
		base_point.node_b = link_point_n.get_path()
		
		base_link = link_point_n
		link_array.append(base_link)
		path_3d.curve.add_point(base_link.position)

func _process(_delta: float) -> void:
	for i in link_array.size():
		path_3d.curve.set_point_position(i,link_array[i].position)
