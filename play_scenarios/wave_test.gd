extends BaseView

@onready var camera_3d_2: Camera3D = $Camera3D2
@onready var camera_3d_3: Camera3D = $Camera3D3
@onready var camera_3d_4: Camera3D = $Camera3D4
@onready var camera_3d_5: Camera3D = $Camera3D5

@onready var water: MeshInstance3D = $Water
@onready var texture_rect: TextureRect = $CanvasLayer/PanelContainer/MarginContainer/TextureRect

var cameras :Array
var cameras_qty : int
var current_int : int = 0
@onready var playable_boat: Node3D = $PlayableBoat
@onready var game_char: Node3D = $GameChar

func _ready() -> void:
	cameras = [
		camera_3d_2,
		game_char.get_player_camera(),
		camera_3d_3,
		camera_3d_4,
		camera_3d_5,
		playable_boat.get_ship_camera()
		]
	cameras_qty=cameras.size()

	var material = water.mesh.surface_get_material(0)

	texture_rect.texture = ImageTexture.create_from_image(material.get_shader_parameter("wave").noise.get_image(512, 512))
#	texture_rect.texture = ImageTexture.create_from_image(waves_h)
	#llamar_ap_procedural(BaseView.data)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_change"):
		current_int =posmod(current_int+1,cameras_qty)
		cameras[current_int].current = true
