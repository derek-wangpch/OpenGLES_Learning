attribute vec4 pos;
attribute vec4 posColor;

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

varying lowp vec4 outColor;

void main() {
    outColor = posColor;
    gl_Position = pos;
}
