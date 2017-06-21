uniform mat4 uProjectionMatrix;
uniform mat4 uModelViewMatrix;

attribute vec3 aPosition;
attribute vec3 aColor;

varying vec3 vColor;

void main()
{
    gl_Position = uProjectionMatrix * uModelViewMatrix * vec4(aPosition, 1.0);
    vColor = aColor;
}
