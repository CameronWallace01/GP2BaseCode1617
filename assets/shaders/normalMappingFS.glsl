#version 410

out vec4 FragColor;

in vec3 vertexNormalOut;
in vec3 cameraDirectionOut;
in vec2 vertexTextureCoordsOut;
in mat3 tangentMatrix;


struct DirectionalLight
{
	vec3 direction;
	vec4 ambientColour;
	vec4 diffuseColour;
	vec4 specularColour;
};

uniform DirectionalLight directionlight;

uniform vec4 ambientMaterialColour=vec4(0.5f,0.0f,0.0f,1.0f);
uniform float specularPower=25.0f;

uniform sampler2D diffuseSampler;
uniform sampler2D specularSampler;
uniform sampler2D normalSampler;

void main()
{
	//get normals from normal map, rescale from 0 to 1 to -1 to 1
	vec3 bumpNormals = 2.0 * texture(normalSampler, vertexTextureCoordsOut).rgb - 1.0;

	//normalize!!
	bumpNormals = normalize(bumpNormals);

	vec3 lightDir=normalize(tangentMatrix * (-directionlight.direction));

	float diffuseTerm = dot(bumpNormals, lightDir);
	vec3 halfWayVec = normalize(cameraDirectionOut + lightDir);
	float specularTerm = pow(dot(bumpNormals, halfWayVec), specularPower);

	vec4 diffuseTextureColour = texture(diffuseSampler, vertexTextureCoordsOut);
	vec4 specularTextureColour = texture(specularSampler, vertexTextureCoordsOut);

	vec4 ambientColour = ambientMaterialColour*directionlight.ambientColour;
	vec4 diffuseColour = diffuseTextureColour*directionlight.diffuseColour*diffuseTerm;
	vec4 specularColour = specularTextureColour*directionlight.specularColour*specularTerm;

	FragColor = (ambientColour + diffuseColour+ specularColour);
}
