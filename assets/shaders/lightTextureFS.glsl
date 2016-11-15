#version 410

out vec4 FragColor;

in vec3 vertexNormalOut;
in vec3 cameraDirectionOut;
in vec2 vertexTextureCoordsOut;
in vec3 worldPos;

struct DirectionalLight
{
	vec3 direction;
	vec4 ambientColour;
	vec4 diffuseColour;
	vec4 specularColour;
};

uniform DirectionalLight directionLight;

struct PointLight
{
	vec3 position;

	vec4 ambientColour;
	vec4 diffuseColour;
	vec4 specularColour;

	float constant;
	float linear;
	float quadratic;
};

uniform PointLight pointLight=PointLight(vec3(0.0f,0.0f,0.0f),vec4(1.0f,1.0f,1.0f,1.0f), vec4(1.0f, 1.0f, 1.0f, 1.0f), vec4(1.0f, 1.0f, 1.0f, 1.0f),1.0f,0.09f,0.032f);

/*
struct SpotLight {
	vec3  position;
	vec3  direction;

	vec4 ambientColour;
	vec4 diffuseColour;
	vec4 specularColour;

	float innerCutOff;
	float outCutOff;
};

uniform SpotLight spotLight;*/

uniform vec4 ambientMaterialColour=vec4(0.5f,0.0f,0.0f,1.0f);
uniform float specularPower=25.0f;

uniform sampler2D diffuseSampler;
uniform sampler2D specularSampler;

vec4 CalculatePointLight(PointLight light, vec3 normal, vec3 cameraDirection)
{
	vec3 lightDir = normalize(light.position - worldPos);
	float diffuseTerm = dot(normal, lightDir);
	vec3 halfWayVec = normalize(cameraDirectionOut + lightDir);
	float specularTerm = pow(dot(normal, halfWayVec), specularPower);

	vec4 diffuseTextureColour = texture(diffuseSampler, vertexTextureCoordsOut);
	vec4 specularTextureColour = texture(specularSampler, vertexTextureCoordsOut);

	vec4 ambientColour = ambientMaterialColour*light.ambientColour;
	vec4 diffuseColour = diffuseTextureColour*light.diffuseColour*diffuseTerm;
	vec4 specularColour = specularTextureColour*light.specularColour*specularTerm;

	float distance = length(light.position - worldPos);
	float attenuation = 1.0f / (light.constant + light.linear * distance +
		light.quadratic * (distance * distance));

	ambientColour *= attenuation;
	diffuseColour *= attenuation;
	specularColour *= attenuation;

	return (ambientColour + diffuseColour + specularColour);
}

vec4 CalculateDirectionalLight(DirectionalLight light, vec3 normal, vec3 cameraDirection)
{
	vec3 lightDir = normalize(-light.direction);
	float diffuseTerm = dot(normal, lightDir);
	vec3 halfWayVec = normalize(cameraDirectionOut + lightDir);
	float specularTerm = pow(dot(normal, halfWayVec), specularPower);

	vec4 diffuseTextureColour = texture(diffuseSampler, vertexTextureCoordsOut);
	vec4 specularTextureColour = texture(specularSampler, vertexTextureCoordsOut);

	vec4 ambientColour = ambientMaterialColour*light.ambientColour;
	vec4 diffuseColour = diffuseTextureColour*light.diffuseColour*diffuseTerm;
	vec4 specularColour = specularTextureColour*light.specularColour*specularTerm;

	return (ambientColour + diffuseColour + specularColour);
}

void main()
{
	vec4 directionalLightColour = CalculateDirectionalLight(directionLight, vertexNormalOut, cameraDirectionOut);
	vec4 pointLightColour = CalculatePointLight(pointLight, vertexNormalOut, cameraDirectionOut);

	FragColor = directionalLightColour+ pointLightColour;
}
