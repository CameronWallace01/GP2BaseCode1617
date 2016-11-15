#version 410

layout(location=0) in vec3 vertexPosition;
layout(location=1) in vec4 vertexColours;
layout(location=2) in vec2 vertexTextureCoords;
layout(location=3) in vec3 vertexNormal;

out vec4 vertexColoursOut;
out vec2 vertexTextureCoordsOut;
out vec3 vertexNormalOut;
out vec3 cameraDirectionOut;
out vec3 worldPos;

uniform mat4 MVP;
uniform mat4 Model;
uniform vec3 cameraPos;

void main()
{
	vertexNormalOut = normalize(Model*vec4(vertexNormal, 0.0f)).xyz;
	worldPos = (Model*vec4(vertexPosition, 1.0)).xyz;
	cameraDirectionOut = normalize(cameraPos - worldPos);

	gl_Position = MVP * vec4(vertexPosition, 1.0);
	vertexColoursOut=vertexColours;
	vertexTextureCoordsOut=vertexTextureCoords;
}
