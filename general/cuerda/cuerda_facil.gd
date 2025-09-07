extends Node3D
@onready var link_point: RigidBody3D = $LinkPoint
@onready var path_3d: Path3D = $Path3D

const LINK_POINT = preload("res://general/cuerda/link_point.tscn")

var link_height :float = .15
var link_array :Array=[] 

func _ready() -> void:


	var base_link =  link_point
	link_array.append(base_link) 
	path_3d.curve.add_point(base_link.position)
	for n in range(32):
		var base_point =  PinJoint3D.new()
		add_child(base_point)
		base_point.position= base_link.position+Vector3(link_height/2,0,0)
		base_point.node_a = base_link.get_path()
		var link_point_n: RigidBody3D = LINK_POINT.instantiate()
		add_child(link_point_n)
		link_point_n.transform = base_link.transform.orthonormalized()
		link_point_n.position += Vector3(link_height,0,0)
		base_point.node_b = link_point_n.get_path()
		
		base_link = link_point_n
		link_array.append(base_link)
		path_3d.curve.add_point(base_link.position)

func _process(_delta: float) -> void:
	for i in link_array.size():
		path_3d.curve.set_point_position(i,link_array[i].position)
