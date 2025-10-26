shader_type spatial;
render_mode unshaded;

//// X: scaling in screenspace/texture u (cos repeats)
//// Y: scaling in screenspace/texture v (offset by +/-1)
//// Z: Scaling in alpha post fresnel
uniform vec3 noise_strength = vec3(.25, .25, .66667);
//// X: Periodicity of pattern sway in U
//// Y: Periodicity in time irregularity of speed in y
//// Z: Fresnel quantity
uniform vec3 noise_speed = vec3(0.075, -1.0, 0.66666666);
//// X/Y/Z: Nonuniform scaling in each dimension maximum.
uniform vec3 displacement_strength = vec3(0.333, .0625, 0.333);
//// X/Y/Z: Timescale for displacement_strength.
uniform vec3 displacement_speed = vec3(2.0, 3.0, 0.5);

varying vec3 offset_uva;

uniform sampler2D noise: source_color, repeat_enable;

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void vertex() {
	VERTEX.x += sign(VERTEX.x) * displacement_strength.x * abs(cos(displacement_speed.x*TIME + VERTEX.y));
	VERTEX.y += sign(VERTEX.y) * displacement_strength.y * abs(cos(displacement_speed.y*TIME + VERTEX.z));
	VERTEX.z += sign(VERTEX.z) * displacement_strength.z * abs(sin(displacement_speed.z*TIME + VERTEX.x));
	
	offset_uva = vec3(
		noise_strength.x * cos(noise_speed.x * (VERTEX.y + TIME)),
		noise_strength.y * (TIME + sin(noise_speed.y * (VERTEX.x + VERTEX.z + TIME))),
		noise_strength.z * (1.0-fresnel(noise_speed.z, NORMAL, CAMERA_DIRECTION_WORLD))
	);
}

void fragment() {
  vec4 col = texture(noise, SCREEN_UV + offset_uva.xy);
  // Set final output
  ALBEDO = col.rgb;
	ALPHA = col.a * offset_uva.z;
}
