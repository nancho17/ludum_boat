extends MeshInstance3D


var material : ShaderMaterial
var noise : Image
var time :float

var noise_scale:float
var wave_speed :float
var height_scale: float


func _ready() -> void: 
	material = mesh.surface_get_material(0)
	var el_noise_texture : NoiseTexture2D = material.get_shader_parameter("wave")#shader_parameter/wave
	await el_noise_texture.changed
	noise = el_noise_texture.get_image()
	#var el_fast_noise_texture : FastNoiseLite = material.get_shader_parameter("wave").noise#shader_parameter/wave
	#noise  = el_fast_noise_texture.get_image(512, 512,false,false,false)

	#noise = material.get_shader_parameter("wave").get_image()#shader_parameter/wave
	noise_scale = material.get_shader_parameter("noise_scale")#shader_parameter/noise_scale
	wave_speed = material.get_shader_parameter("wave_speed")#shader_parameter/wave_speed
	height_scale = material.get_shader_parameter("height_scale")#shader_parameter/height_scale
	set_physics_process(true)
#	noise.get_mipmap_offset()	
	
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
