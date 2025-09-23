extends MeshInstance3D


var material : ShaderMaterial
var noise : Image
var time :float

var noise_scale:float
var wave_speed :float
var height_scale: float
var el_noise_texture : NoiseTexture2D


func _ready() -> void: 
	material = mesh.surface_get_material(0)

	el_noise_texture = material.get_shader_parameter("wave")#shader_parameter/wave


	#var el_fast_noise_texture : FastNoiseLite = material.get_shader_parameter("wave").noise#shader_parameter/wave
	#noise  = el_fast_noise_texture.get_image(512, 512,false,false,false)

	#noise = material.get_shader_parameter("wave").get_image()#shader_parameter/wave
	noise_scale = material.get_shader_parameter("noise_scale")#shader_parameter/noise_scale
	wave_speed = material.get_shader_parameter("wave_speed")#shader_parameter/wave_speed
	height_scale = material.get_shader_parameter("height_scale")#shader_parameter/height_scale

	while el_noise_texture == null or el_noise_texture.get_image() == null:
		await get_tree().process_frame
	noise = el_noise_texture.get_image()

	print("set_physics_process(true)")
	
func _physics_process(delta: float) -> void:
	time+=delta
	material.set_shader_parameter("wave_time",time)#shader_parameter/wave_time
	#print("wave_time: ", time)

func get_height(world_pos: Vector3) -> float:
	if noise == null:
		print("null pa")
		return 0

	var uv_x :float = wrapf(world_pos.x/noise_scale + time * wave_speed,0,1)
	var uv_y :float = wrapf(world_pos.z/noise_scale + time * wave_speed,0,1)
	#var uv_x :float = wrapf(world_pos.x/noise_scale ,0.0,1.0)
	#var uv_y :float = wrapf(world_pos.z/noise_scale ,0.0,1.0)

	var pixel_pos = Vector2(uv_x*noise.get_width(),uv_y*noise.get_height())

	return noise.get_pixelv(pixel_pos).r*height_scale
