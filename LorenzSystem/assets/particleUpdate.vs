#version 150 core

in vec3 iPosition;
in vec4 iColor;

out vec3 position;
out vec4 color;

uniform float uSigma;
uniform float uRho;
uniform float uBeta;
uniform float uDt;

void main()
{
	position = iPosition;
    position += vec3(
        uSigma * (-position.x + position.y),
        position.x * (uRho - position.z) - position.y,
        position.x * position.y - uBeta * position.z
    ) * uDt;

    color = iColor;
}
