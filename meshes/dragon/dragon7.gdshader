shader_type spatial;
render_mode depth_draw_never, cull_front, blend_add;

uniform sampler2D _NoiseTex;
uniform float _Scale : hint_range(0.0, 0.05) = 0.05;
uniform float _Opacity: hint_range(0.01, 10.0) = 10.0;
uniform float _Edge : hint_range(0.0, 1.0) = 0.1;
uniform vec4 _ColorAura = vec4(1.0,0.0,0.0,1.0);
uniform vec4 _ColorRim = vec4(0.0,0.0,1.0,1.0);
uniform float _Brightness: hint_range(0.5, 20.0) = 2.0;
uniform float _SpeedX: hint_range(-10.0, 10.0) = 0.0;
uniform float _SpeedY: hint_range(-10.0, 10.0) = 3.0;
uniform float _OffsetFade: hint_range(-10.0, 10.0) = 1.0;
uniform float _GlowBrightness: hint_range(0.01, 30.0) = 3.0;
uniform float _OutlineFixed: hint_range(0.0, 5.0) = 2.0;
uniform float _RimPower2: hint_range(0.01, 10.0) = 6.0;

void vertex()
{
	VERTEX	 = (NORMAL * _Edge) + VERTEX;
}
float saturate(float value)
{
	return clamp(value,0.0,1.0);
}

void fragment() {
	// noise
	float speedx = TIME * _SpeedX * 0.005;
	float speedy = TIME * _SpeedY * -0.005;
	vec4 n = texture(_NoiseTex, vec2(SCREEN_UV.x * _Scale + speedx, SCREEN_UV.y * _Scale + speedy));
	// same noise, but bigger
	vec4 n2 = texture(_NoiseTex, vec2(SCREEN_UV.x* (_Scale * 0.5) + speedx, SCREEN_UV.y * (_Scale * 0.5) + speedy));
	// same but smaller
	vec4 n3 = texture(_NoiseTex, vec2(SCREEN_UV.x* (_Scale * 2.0) + speedx, SCREEN_UV.y * (_Scale * 2.0) + speedy));
	// combined
	float combinedNoise = (n.r * n2.r * 2.0) * n3.r * 2.0;
	
	float rims = pow(saturate(dot(VIEW, NORMAL)), _RimPower2); // calculate inverted rim based on view and normal
	vec4 rim = vec4(rims);
	rim -= combinedNoise; // subtract noise texture
	rim += (rims * _OutlineFixed);
	vec4 texturedRim = vec4(saturate(rim.a * _Opacity)); // make a harder edge
	vec4 extraRim = (saturate((_Edge + rim.a) * _Opacity) - texturedRim) * _Brightness;// extra edge, subtracting the textured rim
	vec4 result = (_ColorAura * texturedRim) + (_ColorRim * extraRim);// combine both with colors
	float fade = saturate((VERTEX.y + _OffsetFade) * 2.0);
	
	result *= fade;
	
	EMISSION = vec3(result.r, result.g, result.b);
	ALPHA = result.a;
}