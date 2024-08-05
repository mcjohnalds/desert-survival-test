shader_type canvas_item;

uniform float blurriness : hint_range(0.0, 512.0) = 8.0;
uniform int iterations : hint_range(1, 64) = 16;
uniform int quality : hint_range(1, 64) = 4;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

// Sources:
//  - https://xorshaders.weebly.com/tutorials/blur-shaders-5-part-2
//  - https://www.shadertoy.com/view/Xltfzj

void fragment(){
	vec2 uv = FRAGCOORD.xy / (1.0 / SCREEN_PIXEL_SIZE).xy;
	float pi = 6.28;
	vec2 radius = blurriness / (1.0 / SCREEN_PIXEL_SIZE).xy;
	vec4 blurred_tex = texture(screen_texture, uv);
	for(float d = 0.0; d < pi; d += pi / float(iterations)){
		for( float i = 1.0 / float(quality); i <= 1.0; i += 1.0 / float(quality) ){
			vec2 directions = uv + vec2(cos(d), sin(d)) * radius * i;
			blurred_tex += texture(screen_texture, directions);
		}
	}
	blurred_tex /= float(quality) * float(iterations) + 1.0;
	COLOR = blurred_tex;
}