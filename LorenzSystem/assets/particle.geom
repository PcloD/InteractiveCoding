#version 150

layout(points) in;
layout(line_strip, max_vertices = 64) out;

in vec4 vColor[]; // Output from vertex shader for each vertex
out vec4 gColor; // Output to fragment shader

uniform mat4 ciModelViewProjection;
uniform mat4 ciProjectionMatrix;
uniform mat4 ciModelView;

uniform float uSigma;
uniform float uRho;
uniform float uBeta;
uniform int uIteration;
uniform float uDt;

void main()
{
	gColor = vColor[0];

    vec4 position = gl_in[0].gl_Position;
    for(int i = 0; i < uIteration; i++) {
        position.xyz += vec3(
            uSigma * (-position.x + position.y),
            position.x * (uRho - position.z) - position.y,
            position.x * position.y - uBeta * position.z
        ) * uDt;
        gl_Position = ciModelViewProjection * vec4(position.xyz, 1.0);
        EmitVertex();
    }
	
	EndPrimitive();
}
