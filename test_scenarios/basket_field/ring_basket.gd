extends StaticBody3D

@onready var ring_texture: TextureRect = $RingTexture
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	var height_map_shape :HeightMapShape3D = collision_shape_3d.get_shape()
	var heightmap_texture = ring_texture.get_texture()
	var heightmap_image = heightmap_texture.get_image()
	heightmap_image.convert(Image.FORMAT_RF)
	
	var height_min = 0.0
	var height_max = 1.0

	height_map_shape.update_map_data_from_image(heightmap_image, height_min, height_max) 
	print("E")
