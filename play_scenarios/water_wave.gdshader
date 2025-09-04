shader_type spatial;
// Changed render mode - removed depth_draw_always which can cause issues with transparency
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, filter_linear_mipmap;
uniform vec3 albedo : source_color;
uniform vec3 albedo2 : source_color;
uniform vec4 color_deep : source_color;
uniform vec4 color_shallow : source_color;
uniform float metallic : hint_range(0.0, 1.0) = 0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;
uniform sampler2D wave;
uniform float wave_time = 0;
uniform vec2 wave_direction = vec2(2.0,0.0);
uniform vec2 wave_2_direction = vec2(0.0,1.0);
uniform float time_scale : hint_range(0.0, 1.0, 0.005) = 0.025;//hint_range(0.0, 0.2, 0.005) 
uniform float wave_speed : hint_range(0.0, 3.0, 0.005) = 2.0;//hint_range = 2.0;
uniform float noise_scale = 10.0;
uniform float height_scale = 0.15;
uniform float beers_law = 2.0;
uniform float depth_offset = -0.75;
varying float height;
varying vec3 world_pos;
uniform float edge_scale = 0.1;
uniform float near = 0.5;
uniform float far = 100.0;
uniform vec3 edge_color : source_color;


float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

// Fixed depth calculation for Godot 4.3+
float linearize_depth(float depth, float local_near, float local_far) {
	return (2.0 * local_near * local_far) / (local_far + local_near - (depth * 2.0 - 1.0) * (local_far - local_near));
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(wave, world_pos.xz / noise_scale + wave_time * wave_speed).r;
	VERTEX.y += height * height_scale;
}

void fragment() {
	// Get the depth from the depth texture (scene behind water)
	float depth_texture = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	
	// Calculate actual world space depths using the projection matrix method
	// This is more reliable in Godot 4.5
	float scene_depth_world = PROJECTION_MATRIX[3][2] / (depth_texture + PROJECTION_MATRIX[2][2]);
	float water_depth_world = PROJECTION_MATRIX[3][2] / (FRAGCOORD.z + PROJECTION_MATRIX[2][2]);
	
	// Calculate the actual depth difference (positive when objects are behind water)
	float depth_diff = abs(scene_depth_world - water_depth_world);
	
	// Apply the offset and beer's law
	float adjusted_depth = (depth_diff + depth_offset);
	float depth_blend = exp(-adjusted_depth * beers_law);
	depth_blend = clamp(1.0 - depth_blend, 0.0, 1.0);
	
	vec3 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, depth_blend * 2.5).rgb;
	vec3 depth_color = mix(color_shallow.rgb, color_deep.rgb, depth_blend);
	vec3 color = mix(screen_color * depth_color, depth_color * 0.25, depth_blend * 0.5);
	
	// Edge detection using the depth difference
	float edge_blend = smoothstep(0.0, edge_scale, depth_diff);
	
	vec2 time = (TIME * wave_direction) * time_scale;
	vec2 time2 = (TIME * wave_2_direction) * time_scale;
	vec3 normal_blend = mix(texture(texture_normal, world_pos.xz / noise_scale + time).rgb, texture(texture_normal2, world_pos.xz / noise_scale + time2).rgb, 0.5);
	
	float fresnel_factor = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_color = mix(albedo, albedo2, fresnel_factor);
	vec3 depth_color_adj = mix(edge_color, color, edge_blend);
	
	ALBEDO = clamp(surface_color + depth_color_adj, vec3(0.0), vec3(1.0));
	ALPHA = 1.0; // Use the water_alpha uniform instead of hardcoded 1.0
	METALLIC = metallic;
	ROUGHNESS = roughness;
	NORMAL_MAP = normal_blend;
}