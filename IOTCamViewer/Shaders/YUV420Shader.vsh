attribute vec4 position;
attribute vec2 inputTextureCoordinate;
uniform float preferredRotation;

varying vec2 texCoordVarying;

void main()
{
/*
	gl_Position = position;
	texCoordVarying = inputTextureCoordinate;
*/
	mat4 rotationMatrix = mat4( cos(preferredRotation), -sin(preferredRotation), 0.0, 0.0,
							   sin(preferredRotation),  cos(preferredRotation), 0.0, 0.0,
							   0.0,					    0.0, 1.0, 0.0,
							   0.0,					    0.0, 0.0, 1.0);
	gl_Position = position * rotationMatrix;
	texCoordVarying = inputTextureCoordinate;

}
