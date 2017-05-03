#version 150

in vec4	ciPosition;
in vec4	ciColor;

out vec4 vColor;

void main( void )
{
	gl_Position	= ciPosition;
    vColor = ciColor;
}
