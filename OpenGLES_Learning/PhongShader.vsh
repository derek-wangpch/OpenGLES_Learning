uniform mat4 uProjectionMatrix;
uniform mat4 uModelViewMatrix;
uniform mat4 uNormalMatrix;

attribute vec3 aPosition;
attribute vec3 aNormal;

varying vec3 vNormal;
varying vec3 vPosition;

void main()
{
    vNormal = (uNormalMatrix * vec4(aNormal, 0.0)).xyz;
    vPosition = (uModelViewMatrix * vec4(aPosition, 1.0)).xyz;
    gl_Position = uProjectionMatrix * uModelViewMatrix * vec4(aPosition, 1.0);
}
