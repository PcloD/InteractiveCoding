#version 150

in vec4	ciPosition;
in vec4	ciColor;

in vec3	Velocity;
in float Seed;

out vec4 vColor;
out vec3 vVelocity;
out float vSeed;
out mat4 vMatrix;

uniform mat4 ciProjectionMatrix;
uniform mat4 ciModelMatrix;
uniform mat4 ciModelView;
uniform mat4 ciModelViewProjection;
uniform mat3 ciNormalMatrix;
uniform mat4 ciViewMatrix;
uniform mat4 ciViewMatrixInverse;

uniform float uT;

mat4 rotate_angle_axis(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat4(
            oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s, 0.0,
            oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s, 0.0,
            oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c, 0.0,
            0.0, 0.0, 0.0, 1.0
            );
}

// http://stackoverflow.com/questions/349050/calculating-a-lookat-matrix
mat4 look_at_matrix(vec3 forward, vec3 up) {
	vec3 xaxis = cross(forward, up);
	vec3 yaxis = up;
	vec3 zaxis = forward;
	return mat4(
		xaxis.x, yaxis.x, zaxis.x, 0,
		xaxis.y, yaxis.y, zaxis.y, 0,
		xaxis.z, yaxis.z, zaxis.z, 0,
		0, 0, 0, 1
	);
}

void main( void )
{
	gl_Position	= vec4(0, 0, 0, 1.0);
    vColor = ciColor;
    vVelocity = Velocity;
    vSeed = Seed;

    // mat4 rot = rotate_angle_axis(normalize(Velocity), uT);
    mat4 rot = look_at_matrix(vec3(0, 0, 1), vec3(0, 1, 0));

    mat4 model = mat4(
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        ciPosition.x, ciPosition.y, ciPosition.z, 1
    ) * rot;
    // );

    /*
    mat4 model = mat4(
        rot[0][0], rot[1][0], rot[2][0], 0,
        rot[0][1], rot[1][1], rot[2][1], 0,
        rot[0][2], rot[1][2], rot[2][2], 0,
        ciPosition.x, ciPosition.y, ciPosition.z, 1
    );
    */

    vMatrix = ciProjectionMatrix * ciViewMatrix * model;
    // vMatrix = ciProjectionMatrix * ciViewMatrix * ciModelMatrix;
    // vMatrix = ciModelViewProjection;
}
