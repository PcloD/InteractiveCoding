#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_LIGHT_SHADER

uniform float uShininess;
// uniform vec3 uColor0;
// uniform vec3 uColor1;

varying vec3 vPosition;
varying vec3 vViewPosition;
varying vec3 vLightDir;

const vec3 lightDir0 = vec3(0.1, 0.3, 0.5);
const vec3 lightDir1 = vec3(-0.8, -1.0, 1.5);
const vec3 ambient = vec3(0.1);

const vec3 color0 = vec3(13.0 / 255.0, 163.0 / 255.0, 222.0 / 255.0);
const vec3 color1 = vec3(222.0 / 255.0, 107.0 / 255.0, 13.0 / 255.0);

float specular(vec3 lightDir, vec3 viewDir, vec3 norm, float shininess) {
    vec3 halfDir = normalize(lightDir + viewDir);
    return pow(max(0.0, dot(halfDir, norm)), shininess);
}

void main() {  

    vec3 dx = dFdx(vPosition);
    vec3 dy = dFdy(vPosition);
    vec3 normal = normalize(cross(normalize(dx), normalize(dy)));

    vec3 viewDir = normalize(vViewPosition);

    float spec = 0.0;
    spec += specular(normalize(vLightDir), viewDir, normal, uShininess);
    // spec += specular(normalize(lightDir0), viewDir, normal, uShininess);
    // spec += specular(normalize(lightDir1), viewDir, normal, uShininess);

    vec4 color = vec4(vec3(spec) + ambient, 1.0);
    color.rgb *= mix(color0, color1, length(normal.xy));
    gl_FragColor = color;  
}

