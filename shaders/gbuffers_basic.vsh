#version 120
#ifdef GLSLANG
#extension GL_GOOGLE_include_directive : enable
#endif
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
varying vec4 color;
uniform int frameCounter;
uniform float viewWidth, viewHeight;
#include "lib/utility_functions/jitter.glsl"

void main() {
    vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    pos = (gbufferModelViewInverse * vec4(pos,1)).xyz;
    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(pos,1);
    gl_FogFragCoord = length(pos);
    color = gl_Color;
    do { /* } */ } while (false);
    gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}
