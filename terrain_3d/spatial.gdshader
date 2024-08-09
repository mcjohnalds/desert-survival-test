shader_type spatial;

uniform float height_scale = 1.0;
uniform sampler2D texture_height : filter_nearest;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale : hint_range(-16.0, 16.0);

uniform sampler2D texture_ambient_occlusion : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 ao_texture_channel;
uniform float ao_light_affect : hint_range(0.0, 1.0, 0.01);

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

float get_height(vec3 pos) {
	return textureLod(texture_height, pos.xz + 0.5, 0.0).x * height_scale;
}

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
	VERTEX.y += get_height(VERTEX);
    vec2 texel_size = 1.0 / vec2(textureSize(texture_height, 0));
	vec3 north = vec3(VERTEX.x, 0.0, VERTEX.z + texel_size.y);
	vec3 south = vec3(VERTEX.x, 0.0, VERTEX.z - texel_size.y);
	vec3 east = vec3(VERTEX.x + texel_size.x, 0.0, VERTEX.z);
	vec3 west = vec3(VERTEX.x - texel_size.x, 0.0, VERTEX.z);
	north.y = get_height(north);
	south.y = get_height(south);
	east.y = get_height(east);
	west.y = get_height(west);
	NORMAL = normalize(cross(south - north, west - east));
}

void fragment() {
	vec2 base_uv = UV;

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;

	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;

	// Normal Map: Enabled
	NORMAL_MAP = texture(texture_normal, base_uv).rgb;
	NORMAL_MAP_DEPTH = normal_scale;

	// Ambient Occlusion: Enabled
	AO = dot(texture(texture_ambient_occlusion, base_uv), ao_texture_channel);
	AO_LIGHT_AFFECT = ao_light_affect;
}