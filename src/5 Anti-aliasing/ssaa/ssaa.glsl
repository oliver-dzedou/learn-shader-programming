#version 330 core

out vec4 fragColor;

uniform vec2 resolution;
uniform sampler2D scene;
uniform int ssaa_factor;

void main() {
    ivec2 src = ivec2(gl_FragCoord.xy) * ssaa_factor;

    vec4 s0 = texelFetch(scene, src + ivec2(0, 0), 0);
    vec4 s1 = texelFetch(scene, src + ivec2(1, 0), 0);
    vec4 s2 = texelFetch(scene, src + ivec2(0, 1), 0);
    vec4 s3 = texelFetch(scene, src + ivec2(1, 1), 0);

    vec4 color = (s0 + s1 + s2 + s3) * 0.25;
    fragColor = color;
}
