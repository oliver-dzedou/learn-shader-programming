#version 330 core

out vec4 fragColor;

uniform vec2 resolution;
uniform sampler2D scene;
uniform int amount;

vec2 get_uv(vec2 pos) {
    return pos / resolution;
}

void main() {
    vec2 uv = get_uv(gl_FragCoord.xy);

    vec2 grid_uv = round(uv * float(amount)) / float(amount);

    vec4 text = texture(scene, grid_uv);

    fragColor = text;
}
