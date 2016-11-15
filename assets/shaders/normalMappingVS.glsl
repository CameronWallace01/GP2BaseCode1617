#version 410

layout(location=0) in vec3 vertexPosition;
layout(location=1) in vec4 vertexColours;
layout(location=2) in vec2 vertexTextureCoords;
layout(location=3) in vec3 vertexNormal;
layout(location=4) in vec3 vertexTangents;
layout(location=5) in vec3 vertexBinormals;

out vec4 vertexColoursOut;
out vec2 vertexTextureCoordsOut;
out vec3 vertexNormalOut;
out vec3 cameraDirectionOut;
out mat3 tangentMatrix;

uniform mat4 MVP;
uniform mat4 Model;
uniform vec3 lightDirection;
uniform vec3 cameraPos;

void main()
{
	vec3 vertexNormalModel = normalize(Model*vec4(vertexNormal, 0.0f)).xyz;
	vec3 vertexTangentsModel=normalize(Model*vec4(vertexTangents, 0.0f)).xyz;
	vec3 vertexBinormalsModel=normalize(Model*vec4(vertexBinormals, 0.0f)).xyz;
	tangentMatrix=mat3(vertexTangentsModel,vertexBinormalsModel,vertexNormalModel);

	vec3 worldPos = (Model*vec4(vertexPosition, 1.0)).xyz;
	vec3 cameraDir = normalize(cameraPos - worldPos);

	cameraDirectionOut = normalize(tangentMatrix * cameraDir);
	vertexNormalOut = normalize(tangentMatrix * vertexNormalModel);

	gl_Position = MVP * vec4(vertexPosition, 1.0);
	vertexColoursOut=vertexColours;
	vertexTextureCoordsOut=vertexTextureCoords;
}
