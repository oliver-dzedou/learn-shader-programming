#version 330 core

out vec4 fragColor;

uniform vec2 resolution;
uniform sampler2D scene;
uniform float offset;

vec2 get_uv(vec2 pos) {
    return pos / resolution;
}

float get_aspect() {
    return max(resolution.x, resolution.y) / min(resolution.x, resolution.y);
}

void main() {
    vec2 uv = get_uv(gl_FragCoord.xy);

    float dist = distance(uv, vec2(0.5));
    vec4 color = vec4(vec3(0.0), 1.0);
    color.r = texture(scene, uv + dist * offset).r;
    color.g = texture(scene, uv).g;
    color.b = texture(scene, uv - dist * offset).b;
    fragColor = color;
}

