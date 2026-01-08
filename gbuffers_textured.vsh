#version 120
#ifdef GLSLANG
#extension GL_GOOGLE_include_directive : enable
#endif
attribute float mc_Entity;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
varying vec4 color;
varying vec2 coord0;
varying vec2 coord1;
uniform int frameCounter;
uniform float viewWidth, viewHeight;
#include "lib/utility_functions/jitter.glsl"

void main() {
    vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    pos = (gbufferModelViewInverse * vec4(pos,1)).xyz;
    gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(pos,1);
    gl_FogFragCoord = length(pos);
    vec3 normal = normalize(gl_NormalMatrix * gl_Normal);
    normal = (mc_Entity==1.) ? vec3(0,1,0) : (gbufferModelViewInverse * vec4(normal,0)).xyz;
    float light = min(normal.x * normal.x * 0.6f + normal.y * normal.y * 0.25f * (3.0f + normal.y) + normal.z * normal.z * 0.8f, 1.0f);
    color = vec4(gl_Color.rgb * light, gl_Color.a);
    coord0 = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    coord1 = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
}
