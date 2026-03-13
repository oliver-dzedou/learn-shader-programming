#version 330 core

out vec4 fragColor;

uniform vec2 resolution;
uniform sampler2D scene;
uniform float time;

uniform float intensity = 0.0;

float nrand(float x, float y) {
    return fract(sin(dot(vec2(x, y), vec2(12.9898, 78.233))) * 43758.5433);
}

vec2 get_uv(vec2 pos) {
    return pos / resolution;
}

void main() {
    vec2 uv = get_uv(gl_FragCoord.xy);
    if (intensity <= 0.0) {
        fragColor = texture(scene, uv);
    }
    float scan_line_jitter = 0.01 * intensity;
    float horizontal_shake = 0.01 * intensity;
    float color_drift = 0.03 * intensity;

    float jitter = nrand(uv.y, time) * 2.0 - 1.0;
    jitter *= step(0, abs(jitter)) * scan_line_jitter;
    float jump = mix(uv.y, fract(uv.y), 0.0);
    float shake = (nrand(time, 2.0) - 0.5) * horizontal_shake;
    float drift = sin(jump) * color_drift;

    vec4 src1 = texture(scene, fract(vec2(uv.x + jitter + shake, jump)));
    vec4 src2 = texture(scene, fract(vec2(uv.x + jitter + shake + drift, jump)));
    fragColor = vec4(src1.r, src2.g, src1.b, src1.a);
}
