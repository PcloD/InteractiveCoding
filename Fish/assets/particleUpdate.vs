#version 150 core

in vec3 iPosition;
in vec4 iColor;
in vec3 iVelocity;
in float iSeed;

out vec3 position;
out vec4 color;
out vec3 velocity;
out float seed;

uniform float uDt;

void main()
{
	position = iPosition + iVelocity * uDt;
    color = iColor;
    velocity = iVelocity;
    seed = iSeed;
}
