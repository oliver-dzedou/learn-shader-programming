#version 330 core

out vec4 fragColor;

#define saturate(i) clamp(i,0.,1.)
#define lofi(i,d) floor(i/d)*d
#define validuv(v) (abs(v.x-0.5)<0.5&&abs(v.y-0.5)<0.5)

const vec2 V = vec2(0.,1.);
const float PI = 3.14159265;
const float HUGE = 1E9;
const int SAMPLES = 6;

uniform vec2 resolution;
uniform float time;
uniform sampler2D texture0;
uniform sampler2D scene;

float hash(vec2 p){
    p = fract(p * vec2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

float v2random(vec2 uv) {
    return hash(mod(uv, vec2(1.0)));
}

mat2 rotate2D( float t ) {
  return mat2( cos( t ), sin( t ), -sin( t ), cos( t ) );
}

vec3 rgb2yiq( vec3 rgb ) {
  return mat3( 0.299, 0.596, 0.211, 0.587, -0.274, -0.523, 0.114, -0.322, 0.312 ) * rgb;
}

vec3 yiq2rgb( vec3 yiq ) {
  return mat3( 1.000, 1.000, 1.000, 0.956, -0.272, -1.106, 0.621, -0.647, 1.703 ) * yiq;
}

vec3 vhsTex2D( vec2 uv, float rot ) {
  if ( validuv( uv ) ) {
    vec3 yiq = vec3( 0.0 );
    for ( int i = 0; i < SAMPLES; i ++ ) {
      yiq += (
        rgb2yiq( texture( scene, uv - vec2( float( i ), 0.0 ) / resolution ).xyz ) *
        vec2( float( i ), float( SAMPLES - 1 - i ) ).yxx / float( SAMPLES - 1 )
      ) / float( SAMPLES ) * 2.0;
    }
    if ( rot != 0.0 ) { yiq.yz = rotate2D( rot ) * yiq.yz; }
    return yiq2rgb( yiq );
  }
  return vec3( 0.1, 0.1, 0.1 );
}

vec2 get_uv(vec2 pos) {
    return pos / resolution;
}

void main() {
  vec2 uv = get_uv(gl_FragCoord.xy);

  vec2 uvn = uv;
  vec3 col = vec3( 0.0, 0.0, 0.0 );

  // tape wave
  uvn.x += ( v2random( vec2( uvn.y / 10.0, time / 10.0 ) / 1.0 ) - 0.5 ) / resolution.x * 1.0;
  uvn.x += ( v2random( vec2( uvn.y, time * 10.0 ) ) - 0.5 ) / resolution.x * 1.0;

  // tape crease
  float tcPhase = smoothstep( 0.9, 0.96, sin( uvn.y * 8.0 - ( time + 0.14 * v2random( time * vec2( 0.67, 0.59 ) ) ) * PI * 1.2 ) );
  float tcNoise = smoothstep( 0.3, 1.0, v2random( vec2( uvn.y * 4.77, time ) ) );
  float tc = tcPhase * tcNoise;
  uvn.x = uvn.x - tc / resolution.x * 8.0;

  // switching noise
  float snPhase = smoothstep( 6.0 / resolution.y, 0.0, uvn.y );
float shiftedY = uvn.y + snPhase * 0.3;
uvn.y = min(shiftedY, uv.y);
  uvn.x += snPhase * ( ( v2random( vec2( uv.y * 100.0, time * 10.0 ) ) - 0.5 ) / resolution.x * 24.0 );

  // fetch
  col = vhsTex2D( uvn, tcPhase * 0.2 + snPhase * 2.0 );



  // ac beat
  col *= 1.0 + 0.1 * smoothstep( 0.4, 0.6, v2random( vec2( 0.0, 0.1 * ( uv.y + time * 0.2 ) ) / 10.0 ) );

  // color noise
  col *= 0.9 + 0.1 * vec3(
        v2random(mod( uvn * vec2( 1.0, 1.0 ) + time * vec2( 5.97, 4.45 ), vec2(1.0) ))
    );
  col = saturate( col );

  // yiq
  col = rgb2yiq( col );
  col = vec3( 0.03, -0.03, 0.00 ) + vec3( 0.97, 1.03, 1.05 ) * col;
  col = yiq2rgb( col );

  fragColor = vec4( col, 1.0 );
}
