uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

attribute vec3 position;
attribute vec3 color;

varying vec3 outColor;

void main()
{
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
    outColor = color;
}
