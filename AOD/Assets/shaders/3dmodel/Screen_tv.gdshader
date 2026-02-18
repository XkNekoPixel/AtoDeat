shader_type spatial;

uniform bool enable_noise = false;
uniform bool enable_black_screen_when_noise_off = false;
uniform sampler2D texture_albedo : source_color, hint_default_white;
uniform float speed : hint_range(1.0, 30.0) = 15.0;
uniform float pixel_size : hint_range(0.001, 0.02) = 0.004;
uniform float brightness : hint_range(1.0, 5.0) = 2.0;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.3;
uniform float scanline_speed : hint_range(0.0, 5.0) = 1.5;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
    vec4 original = texture(texture_albedo, UV);

    vec2 pixelated = floor(UV / pixel_size) * pixel_size;

    float t = floor(TIME * speed);
    float n = rand(pixelated + t);
    float n2 = rand(pixelated * 1.3 + t + 5.0);
    float noise_val = mix(n, n2, 0.5);

    float scanline = sin(UV.y * 80.0 + TIME * scanline_speed * 10.0) * 0.5 + 0.5;
    scanline = mix(1.0, scanline, scanline_strength);

    float band = smoothstep(0.4, 0.6, rand(vec2(floor(UV.y * 6.0), t * 0.3)));
    noise_val = mix(noise_val, noise_val * 1.5, band * 0.4);

    vec3 noise_color = vec3(noise_val) * scanline * brightness;
    
    if (enable_noise) {
        ALBEDO = noise_color;
        EMISSION = noise_color * 0.6;
    } else {
        if (enable_black_screen_when_noise_off) {
            ALBEDO = vec3(0.0);
            EMISSION = vec3(0.0);
        } else {
            ALBEDO = original.rgb;
            EMISSION = vec3(0.0);
        }
    }
}