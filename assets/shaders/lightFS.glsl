#version 410

out vec4 FragColor;

in vec3 vertexNormalOut;
in vec3 cameraDirectionOut;

struct DirectionalLight
{
	vec3 direction;
	vec4 ambientColour;
	vec4 diffuseColour;
	vec4 specularColour;
};

uniform DirectionalLight directionlight;

uniform vec4 ambientMaterialColour=vec4(0.5f,0.0f,0.0f,1.0f);
uniform vec4 diffuseMaterialColour=vec4(0.8f,0.0f,0.0f,1.0f);
uniform vec4 specularMaterialColour=vec4(1.0f,1.0f,1.0f,1.0f);
uniform float specularPower=25.0f;

void main()
{
	vec3 lightDir=normalize(-directionlight.direction);
	float diffuseTerm = dot(vertexNormalOut, lightDir);
	vec3 halfWayVec = normalize(cameraDirectionOut + lightDir);
	float specularTerm = pow(dot(vertexNormalOut, halfWayVec), specularPower);

	FragColor = (ambientMaterialColour*directionlight.ambientColour) + (diffuseMaterialColour*directionlight.diffuseColour*diffuseTerm) + (specularMaterialColour*directionlight.specularColour*specularTerm);
}
