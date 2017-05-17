#version 150

layout(points) in;
layout(triangle_strip, max_vertices = 128) out;

in vec4 vColor[];
in vec3 vVelocity[];
in float vSeed[];
in mat4 vMatrix[];

out vec4 gColor; 
out vec3 gPosition;

// uniform mat4 ciProjectionMatrix;
// uniform mat4 ciViewMatrix;
// uniform mat4 ciModelView;
uniform mat4 ciModelViewProjection;

uniform float uT;

// Constructing 3D Geometric Fish Models
// http://www.dgp.toronto.edu/~tu/thesis/node63.html

void corner(vec3 spine, float width, float height, out vec3 lt, out vec3 rt, out vec3 rb, out vec3 lb) {
    float hw = width * 0.5;
    float hh = height * 0.5;
    lt = spine + vec3(-hw, hh, 0);
    rt = spine + vec3(hw, hh, 0);
    rb = spine + vec3(hw, -hh, 0);
    lb = spine + vec3(-hw, -hh, 0);
}

void outputVertex() {
    gPosition = gl_Position.xyz;
    EmitVertex();
}

void triangle(vec3 p0, vec3 p1, vec3 p2) {
    // mat4 m = ciModelViewProjection;
    mat4 m = vMatrix[0];
    gl_Position = m * vec4(p0, 1.0); outputVertex();
    gl_Position = m * vec4(p1, 1.0); outputVertex();
    gl_Position = m * vec4(p2, 1.0); outputVertex();
    EndPrimitive();
}

void quad(vec3 p0, vec3 p1, vec3 p2, vec3 p3) {
    // mat4 m = ciModelViewProjection;
    mat4 m = vMatrix[0];
    gl_Position = m * vec4(p0, 1.0); outputVertex();
    gl_Position = m * vec4(p1, 1.0); outputVertex();
    gl_Position = m * vec4(p3, 1.0); outputVertex();
    gl_Position = m * vec4(p2, 1.0); outputVertex();
    EndPrimitive();
}

void side(
    vec3 lt0, vec3 rt0, vec3 rb0, vec3 lb0,
    vec3 lt1, vec3 rt1, vec3 rb1, vec3 lb1
) {
    quad(lt0, rt0, rt1, lt1);
    quad(rt0, rb0, rb1, rt1);
    quad(rb0, lb0, lb1, rb1);
    quad(lb0, lt0, lt1, lb1);
}

vec3 wave(vec3 ori, vec3 vel, vec3 p) {
    /*
    vec3 right = vec3(1.0, 0.0, 0.0);
    float intensity = length(vel);
    // float intensity = 0.1;
    float d = length(p - ori);
    float offset = vSeed[0] * 10.0;
    return p + right * sin((offset + uT) + d * 1.45) * intensity * pow(d, 0.75);
    */
    return p;
}

void main()
{
	gColor = vColor[0];

    // vec4 position = gl_in[0].gl_Position;
    vec4 position = vec4(0, 0, 0, 1);

    vec3 vel = vVelocity[0];

    // head
    vec3 head = position.xyz + vec3(0, 0, 0.5);
    vec3 spine = position.xyz;

    vec3 lt0, rt0, rb0, lb0;
    corner(wave(head, vel, spine), 0.7, 0.8, lt0, rt0, rb0, lb0);

    triangle(lt0, head, rt0);
    triangle(rt0, head, rb0);
    triangle(rb0, head, lb0);
    triangle(lb0, head, lt0);

    vec3 lt1, rt1, rb1, lb1;
    spine += vec3(0, 0, -0.5);
    corner(wave(head, vel, spine), 0.8, 1.0, lt1, rt1, rb1, lb1);

    side(
        lt0, rt0, rb0, lb0,
        lt1, rt1, rb1, lb1
    );

    vec3 lt2, rt2, rb2, lb2;
    spine += vec3(0, 0, -0.5);
    corner(wave(head, vel, spine), 0.7, 0.8, lt2, rt2, rb2, lb2);

    side(
        lt1, rt1, rb1, lb1,
        lt2, rt2, rb2, lb2
    );

    vec3 lt3, rt3, rb3, lb3;
    spine += vec3(0, 0, -0.2);
    corner(wave(head, vel, spine), 0.5, 0.5, lt3, rt3, rb3, lb3);

    side(
        lt2, rt2, rb2, lb2,
        lt3, rt3, rb3, lb3
    );

    vec3 lt4, rt4, rb4, lb4;
    spine += vec3(0, 0, -0.3);
    corner(wave(head, vel, spine), 0.2, 0.2, lt4, rt4, rb4, lb4);

    side(
        lt3, rt3, rb3, lb3,
        lt4, rt4, rb4, lb4
    );

    vec3 tailt = wave(head, vel, spine + vec3(0, 0.5, -0.5));
    vec3 tailb = wave(head, vel, spine + vec3(0, -0.5, -0.5));

    triangle(lt4, rt4, tailt);
    quad(rt4, rb4, tailb, tailt);
    triangle(rb4, lb4, tailb);
    quad(lb4, lt4, tailt, tailb);

}
