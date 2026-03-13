#version 330 core

#define INTENSITY 0.98

out vec4 fragColor;

uniform vec2 resolution;
uniform sampler2D scene;

void main()
{
    vec2 uv = gl_FragCoord.xy / resolution;
    vec2 centered = uv - 0.5;

    float aspect = resolution.x / resolution.y;
    centered.x *= aspect;

    float dist = length(centered);

    float maxDist = length(vec2(0.5 * aspect, 0.5));

    float d = dist / maxDist;

    float inner = 0.75;
    float outer = 1.0;

    float t = smoothstep(inner, outer, d * (INTENSITY));

    float vignette = 1.0 - t;

    vec4 scene_color = texture(scene, uv);
    fragColor = vec4(scene_color.rgb * vignette, scene_color.a);
}
