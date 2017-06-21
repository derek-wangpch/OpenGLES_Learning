precision mediump float;

uniform vec3 uEyePos;

varying vec3 vNormal;
varying vec3 vPosition;

const vec3 myLightPosition = vec3(0.0, 0.0, 1.0);
const vec3 myLightAmbient = vec3(0.2, 0.2, 0.2);
const vec3 myLightDiffuse = vec3(0.2, 0.7, 0.2);
const vec3 myLightSpecular = vec3(1.0, 1.0, 1.0);

const vec3 myMaterialAmbient   = vec3(0.4, 0.8, 0.4);
const vec3 myMaterialDiffuse   = vec3(1.0, 1.0, 1.0);
const vec3 myMaterialSpecular  = vec3(1.0, 1.0, 1.0);
const float myMaterialShininess = 100.0;

vec3 ADSLightModel( in vec3 myNormal, in vec3 myPosition ) {
    vec3 norm = normalize(myNormal);
    vec3 lightV = normalize(myLightPosition - myPosition);
    vec3 viewV = normalize(uEyePos - myPosition);
    vec3 refl = reflect(-lightV, norm);

    // Ambient light
    vec3 ambient = myMaterialAmbient * myLightAmbient;
    // Diffuse light
    vec3 diffuse = max(0.0, dot(norm, lightV)) * myLightDiffuse * myMaterialDiffuse;
    // TODO: Add diffuse attenuation item
    // Specular light
    vec3 specular =vec3(0,0,0);
    if(dot(lightV, viewV) > 0.0) {
        specular = pow(max(0.0, dot(viewV, refl)), myMaterialShininess) * myLightSpecular * myMaterialSpecular;
    }
    return clamp(ambient + diffuse + specular, 0.0, 1.0);
}

void main()
{
    vec3 color = ADSLightModel(vNormal, vPosition);
    gl_FragColor = vec4(color, 1.0);
}
