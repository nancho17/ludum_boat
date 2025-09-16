# Turret.gd (Godot 4)
extends Node3D

@export var mouse_sensitivity := 0.005         # ajustá al gusto
@export var invert_y := false                  # invertir eje Y si querés
@export var min_pitch_deg := -10.0             # límite hacia abajo
@export var max_pitch_deg :=  50.0             # límite hacia arriba
@export var launch_force := 80.0
@export var harpoon_scene: PackedScene

@onready var pivot_yaw: Node3D = $PivotYaw
@onready var pivot_roll: Node3D = $PivotYaw/PivotRoll
@onready var turret_camera: Camera3D = $PivotYaw/PivotRoll/Camera3D
@onready var e_to_use_text: MeshInstance3D = $InstructionText
@onready var marker_3d: Marker3D = $PivotYaw/PivotRoll/Marker3D

var can_interact := false
var using_turret := false
var pitch := 0.0   # en radianes, controlamos el ángulo acumulado
var yaw := 0.0

func _ready() -> void:
	# Inicializamos yaw/pitch desde la rotación actual de los pivotes
	yaw = pivot_yaw.rotation.y
	pitch = pivot_roll.rotation.x

func enter_turret_mode() -> void:
	using_turret = true
	turret_camera.current = true
	e_to_use_text.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func exit_turret_mode() -> void:
	using_turret = false
	turret_camera.current = false
	e_to_use_text.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func fire() -> void:
	if harpoon_scene == null:
		return
	var harpoon = harpoon_scene.instantiate() as RigidBody3D
	get_tree().current_scene.add_child(harpoon)
	harpoon.global_transform = marker_3d.global_transform
	harpoon.linear_velocity = marker_3d.global_transform.basis.x * launch_force
	
func _process(_delta):
		if can_interact and Input.is_action_pressed("app_interact"):
			enter_turret_mode()
		if using_turret and Input.is_action_just_pressed("app_fire"):
			fire()

func _unhandled_input(event: InputEvent) -> void:
	if not using_turret:
		return

	if event is InputEventMouseMotion:
		var rel: Vector2 = event.relative

		# YAW (izq/der) → rotación alrededor del eje Y
		# Nota: usamos el delta X del mouse; el signo negativo suele sentirse “natural”
		yaw -= rel.x * mouse_sensitivity

		# PITCH (arriba/abajo) → rotación alrededor del eje X
		var y_factor := 1.0 if invert_y else -1.0
		pitch += rel.y * mouse_sensitivity * y_factor

		# Limitar pitch (en radianes)
		var min_pitch := deg_to_rad(min_pitch_deg)
		var max_pitch := deg_to_rad(max_pitch_deg)
		pitch = clamp(pitch, min_pitch, max_pitch)

		# Aplicar a los pivotes
		pivot_yaw.rotation.y = yaw
		pivot_roll.rotation.z = pitch

	# Salir del modo torreta (ejemplo con tecla ESC)
	if event.is_action_pressed("ui_cancel"):
		exit_turret_mode()


func _on_area_3d_body_entered(body: Node3D) -> void:
	can_interact = true
	e_to_use_text.visible = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	can_interact = false
	e_to_use_text.visible = false
	
