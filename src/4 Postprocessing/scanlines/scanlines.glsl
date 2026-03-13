#version 330 core

out vec4 fragColor;

uniform vec2 resolution;
uniform sampler2D scene;
uniform float amount;
uniform float mix_factor;

float scanlines(float x, float repeat) {
    x = floor(x * repeat);
    return mod(x, 2.0);
}

void main()
{
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    float scan = scanlines(uv.y, amount);

    vec4 samp = texture(scene, uv);
    fragColor.rgb = mix(samp.rgb, vec3(scan), mix_factor);
    fragColor.a = samp.a;
}

