#version 150

in vec4 gColor;
in vec3 gPosition;

out vec4 oColor;

void main()
{
    vec3 dx = dFdx(gPosition);
    vec3 dy = dFdy(gPosition);
    vec3 normal = normalize(cross(normalize(dx), normalize(dy)));

    oColor = vec4((normal + 1.0) * 0.5, 1.0);
}
