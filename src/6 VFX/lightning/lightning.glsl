#version 330 core

out vec4 fragColor;

in vec2 fragTexCoord;

uniform float time;
uniform vec2 resolution;

const int lightning_number = 5;
const vec2 amplitude = vec2(2.0,1.0);
const float offset = 0.45;
const float thickness = 0.02;
const float speed = 2.0;
const vec4 base_color = vec4(0.270, 0.470, 0.929, 1);
const float glow_thickness = 0.08;
const vec4 glow_color = vec4(0.270, 0.470, 0.929, 1);
const float alpha  = 1.0;

// plot function 
float plot(vec2 st, float pct, float half_width){
  return  smoothstep( pct-half_width, pct, st.y) -
          smoothstep( pct, pct+half_width, st.y);
}

vec2 hash22(vec2 uv) {
    uv = vec2(dot(uv, vec2(127.1,311.7)),
              dot(uv, vec2(269.5,183.3)));
    return 2.0 * fract(sin(uv) * 43758.5453123) - 1.0;
}

float noise(vec2 uv) {
    vec2 iuv = floor(uv);
    vec2 fuv = fract(uv);
    vec2 blur = smoothstep(0.0, 1.0, fuv);
    return mix(mix(dot(hash22(iuv + vec2(0.0,0.0)), fuv - vec2(0.0,0.0)),
                   dot(hash22(iuv + vec2(1.0,0.0)), fuv - vec2(1.0,0.0)), blur.x),
               mix(dot(hash22(iuv + vec2(0.0,1.0)), fuv - vec2(0.0,1.0)),
                   dot(hash22(iuv + vec2(1.0,1.0)), fuv - vec2(1.0,1.0)), blur.x), blur.y) + 0.5;
}

float fbm(vec2 n) {
    float total = 0.0, amp = 1.0;
    for (int i = 0; i < 7; i++) {
        total += noise(n) * amp;
        n += n;
        amp *= 0.5;
    }
    return total;
}



void main(){
    vec2 uv = fragTexCoord;

	vec4 color = vec4(0.0, 0.0, 0.0, 0.0);
	
	vec2 t;
	float y ;
	float pct ;
	float buf;	
	// add more lightning
	for ( int i = 0; i < lightning_number; i++){
		t = uv * amplitude + vec2(float(i), -float(i)) - time*speed;
		y = fbm(t)*offset;
		pct = plot(uv, y, thickness);
		buf = plot(uv, y, glow_thickness);
		color *= pct*base_color;
		color += buf*glow_color;
	}
	
	color.a *= alpha;
	fragColor = color;
}