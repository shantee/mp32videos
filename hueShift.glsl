// hueShift.glsl

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform float hueShift;

varying vec4 vertColor;
varying vec2 vTexCoord;

void main() {
    vec4 color = texture2D(texture, vTexCoord);

    // Conversion de RGB à HSV
    float cMax = max(color.r, max(color.g, color.b));
    float cMin = min(color.r, min(color.g, color.b));
    float delta = cMax - cMin;

    float hue = 0.0;
    if (delta != 0.0) {
        if (cMax == color.r) {
            hue = mod(((color.g - color.b) / delta), 6.0);
        } else if (cMax == color.g) {
            hue = ((color.b - color.r) / delta) + 2.0;
        } else {
            hue = ((color.r - color.g) / delta) + 4.0;
        }
        hue /= 6.0;
    }

    float saturation = (cMax == 0.0) ? 0.0 : delta / cMax;
    float value = cMax;

    // Décalage de la teinte
    hue = mod(hue + hueShift, 1.0);

    // Conversion de HSV à RGB
    float c = value * saturation;
    float x = c * (1.0 - abs(mod(hue * 6.0, 2.0) - 1.0));
    float m = value - c;

    vec3 rgb;

    if (hue < 1.0/6.0) {
        rgb = vec3(c, x, 0.0);
    } else if (hue < 2.0/6.0) {
        rgb = vec3(x, c, 0.0);
    } else if (hue < 3.0/6.0) {
        rgb = vec3(0.0, c, x);
    } else if (hue < 4.0/6.0) {
        rgb = vec3(0.0, x, c);
    } else if (hue < 5.0/6.0) {
        rgb = vec3(x, 0.0, c);
    } else {
        rgb = vec3(c, 0.0, x);
    }

    gl_FragColor = vec4(rgb + m, color.a);
}
