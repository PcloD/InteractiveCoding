#version 150

in vec4 gColor;

out vec4 oColor;

void main( void )
{
    oColor = gColor;
    oColor.a *= 0.7;
}
