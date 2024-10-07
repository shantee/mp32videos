// hueShift.vert

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

attribute vec4 vertexPosition;
attribute vec4 vertexColor;
attribute vec2 vertexTexCoord;

uniform mat4 transformMatrix;
uniform mat4 projectionMatrix;
uniform mat4 modelviewMatrix;

varying vec4 vertColor;
varying vec2 vTexCoord;

void main() {
    gl_Position = projectionMatrix * modelviewMatrix * vertexPosition;
    vertColor = vertexColor;
    vTexCoord = vertexTexCoord;
}
