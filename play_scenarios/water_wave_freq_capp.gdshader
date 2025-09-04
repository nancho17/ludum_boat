shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture;
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
uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.025;
uniform float wave_speed : hint_range(0.0, 0.4, 0.001) = 0.1;
uniform float noise_scale = 10.0;
uniform float height_scale = 0.15;
uniform float beers_law = 2.0;
uniform float depth_offset = -0.75;

// New smooth wave controls
uniform float wave_frequency_1 : hint_range(0.1, 5.0) = 1.0;
uniform float wave_frequency_2 : hint_range(0.1, 5.0) = 1.5;
uniform float wave_frequency_3 : hint_range(0.1, 5.0) = 0.3;
uniform float wave_amplitude_1 : hint_range(0.0, 1.0) = 1.0;
uniform float wave_amplitude_2 : hint_range(0.0, 1.0) = 0.5;
uniform float wave_amplitude_3 : hint_range(0.0, 1.0) = 0.2;
uniform float wave_steepness : hint_range(0.0, 2.0) = 1.0;
uniform float smoothness : hint_range(0.1, 4.0) = 2.0; // Low-pass filter strength

varying float height;
varying vec3 world_pos;
uniform float edge_scale = 0.1;
uniform float near = 0.5;
uniform float far = 100.0;
uniform vec3 edge_color : source_color;
uniform float water_alpha : hint_range(0.5, 1.0) = 0.8;

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

// Smooth wave function using multiple octaves
float smooth_wave(vec2 pos, float time) {
	// Primary large waves
	float wave1 = sin(dot(pos, wave_direction.xy) * wave_frequency_1 + time * wave_speed) * wave_amplitude_1;
	
	// Secondary medium waves
	float wave2 = sin(dot(pos, wave_2_direction.xy) * wave_frequency_2 + time * wave_speed * 0.7) * wave_amplitude_2;
	
	// Tertiary small waves for detail
	float wave3 = sin(dot(pos, normalize(wave_direction + wave_2_direction)) * wave_frequency_3 + time * wave_speed * 1.3) * wave_amplitude_3;
	
	// Combine waves with different phases for complexity
	float combined = wave1 + wave2 + wave3;
	
	// Apply smoothness (low-pass filter simulation)
	// Using a smoothstep-based approach to reduce high frequency noise
	combined = smoothstep(-smoothness, smoothness, combined * 2.0) - 0.5;
	
	// Add some texture-based detail but filtered
	float texture_detail = texture(wave, pos / noise_scale + time * time_scale).r - 0.5;
	texture_detail = smoothstep(-0.3, 0.3, texture_detail); // Filter high frequencies
	
	return combined + texture_detail * 0.3;
}

// Gerstner wave function for more realistic wave motion
vec3 gerstner_wave(vec2 pos, float time, vec2 direction, float frequency, float amplitude, float steepness) {
	float phase = frequency * dot(direction, pos) + time * wave_speed;
	float steep = steepness / (frequency * amplitude);
	
	vec3 result;
	result.x = steep * amplitude * direction.x * cos(phase);
	result.z = steep * amplitude * direction.y * cos(phase);
	result.y = amplitude * sin(phase);
	
	return result;
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	height = texture(wave, world_pos.xz / noise_scale + wave_time * wave_speed).r;
	// Method 1: Simple smooth waves (faster)
//	height = smooth_wave(world_pos.xz, wave_time);
	VERTEX.y += height * height_scale;
	
	// Method 2: Gerstner waves (more realistic but more expensive)
	// Uncomment this block and comment the above for Gerstner waves
	/*
	vec3 gerstner1 = gerstner_wave(world_pos.xz, wave_time, normalize(wave_direction), 
	                               wave_frequency_1, wave_amplitude_1 * height_scale, wave_steepness);
	vec3 gerstner2 = gerstner_wave(world_pos.xz, wave_time, normalize(wave_2_direction), 
	                               wave_frequency_2, wave_amplitude_2 * height_scale, wave_steepness * 0.7);
	
	VERTEX.xyz += gerstner1 + gerstner2;
	height = gerstner1.y + gerstner2.y;
	*/
}

void fragment() {
	// Get the depth from the depth texture (scene behind water)
	float depth_texture = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	
	// Calculate actual world space depths using the projection matrix method
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
	
	// Smooth normal blending with filtered time
	vec2 time = (TIME * wave_direction) * time_scale;
	vec2 time2 = (TIME * wave_2_direction) * time_scale;
	
	// Apply smoothness to normal sampling as well
	vec3 normal1 = texture(texture_normal, world_pos.xz / noise_scale + time).rgb;
	vec3 normal2 = texture(texture_normal2, world_pos.xz / noise_scale + time2).rgb;
	vec3 normal_blend = mix(normal1, normal2, 0.5);
	
	// Smooth the normals to reduce high frequency noise
	normal_blend = normalize(mix(vec3(0.5, 0.5, 1.0), normal_blend, 0.8));
	
	float fresnel_factor = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_color = mix(albedo, albedo2, fresnel_factor);
	vec3 depth_color_adj = mix(edge_color, color, edge_blend);
	
	ALBEDO = clamp(surface_color + depth_color_adj, vec3(0.0), vec3(1.0));
	ALPHA = water_alpha;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	NORMAL_MAP = normal_blend;
}