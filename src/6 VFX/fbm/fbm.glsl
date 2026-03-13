#version 330 core

out vec4 fragColor;

uniform vec2 resolution;
uniform float time;
uniform vec3 target_color;

vec2 hash2(float n)
{
    return fract(sin(vec2(n, n + 1.0)) * vec2(13.5453123, 31.1459123));
}

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(in vec2 x) {
    vec2 p = floor(x);
    vec2 f = fract(x);

    f = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

    float a = hash(p + vec2(0.0, 0.0));
    float b = hash(p + vec2(1.0, 0.0));
    float c = hash(p + vec2(0.0, 1.0));
    float d = hash(p + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

const mat2 mtx = mat2(0.80, 0.60, -0.60, 0.80);

float fbm(vec2 p)
{
    float f = 0.0;

    f += 0.500000 * noise(p);
    p = mtx * p * 2.02;

    return f / 0.96875;
}

float pattern(in vec2 p, in float t, in vec2 uv, out vec2 q, out vec2 r, out vec2 g)
{
    q = vec2(fbm(p), fbm(p + vec2(10, 1.3)));

    float s = dot(uv.x + 0.5, uv.y + 0.5);
    r = vec2(fbm(p + 4.0 * q + vec2(t) + vec2(1.7, 9.2)), fbm(p + 4.0 * q + vec2(t) + vec2(8.3, 2.8)));
    g = vec2(fbm(p + 2.0 * r + vec2(t * 20.0) + vec2(2, 6)), fbm(p + 2.0 * r + vec2(t * 10.0) + vec2(5, 3)));
    return fbm(p + 5.5 * g + vec2(-t * 7.0));
}

void main()
{
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    vec2 q, r, g;
    float noise = pattern(uv * 16.0, time * 0.007, uv, q, r, g);
    vec3 col = mix(vec3(0.0, 0.0, 0.0), target_color, smoothstep(0.0, 1.0, noise));
    col = mix(col, vec3(0), smoothstep(0.7, 0.8, noise) * smoothstep(0.8, 0.7, noise));

    // some dark outlines/contrast and different steps
    col = mix(col, vec3(0), smoothstep(0.3, 0.5, noise) * smoothstep(0.5, 0.3, noise));
    col = mix(col, vec3(0), smoothstep(0.7, 0.8, noise) * smoothstep(0.8, 0.7, noise));
    fragColor = vec4(col, 1.0);
}
