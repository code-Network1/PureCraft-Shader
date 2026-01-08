#version 130
#ifdef GLSLANG
#extension GL_GOOGLE_include_directive : enable
#endif
#include "lib/shader_config.glsl"

uniform sampler2D colortex1;
uniform float viewWidth;
uniform float viewHeight;
in vec2 coord0;
out vec4 fragColor;

#ifndef SHARPENING
void SharpenFilter(inout vec3 color, vec2 coord) {}
#else
#define textureLod0Offset(img, coord, offset) textureLodOffset(img, coord, 0.0f, offset)
#define textureLod0(img, coord) textureLod(img, coord, 0.0f)

void SharpenFilter(inout vec3 color, vec2 textureCoord) {
    vec3 a = textureLod0Offset(colortex1, textureCoord, ivec2(-1,-1)).rgb;
    vec3 b = textureLod0Offset(colortex1, textureCoord, ivec2( 0,-1)).rgb;
    vec3 c = textureLod0Offset(colortex1, textureCoord, ivec2( 1,-1)).rgb;
    vec3 d = textureLod0Offset(colortex1, textureCoord, ivec2(-1, 0)).rgb;
    vec3 e = color;
    vec3 f = textureLod0Offset(colortex1, textureCoord, ivec2( 1, 0)).rgb;
    vec3 g = textureLod0Offset(colortex1, textureCoord, ivec2(-1, 1)).rgb;
    vec3 h = textureLod0Offset(colortex1, textureCoord, ivec2( 0, 1)).rgb;
    vec3 i = textureLod0Offset(colortex1, textureCoord, ivec2( 1, 1)).rgb;
    
    vec3 mnRGB  = min(min(min(d,e),min(f,b)),h);
    vec3 mnRGB2 = min(min(min(mnRGB,a),min(g,c)),i);
    mnRGB += mnRGB2;
    vec3 mxRGB  = max(max(max(d,e),max(f,b)),h);
    vec3 mxRGB2 = max(max(max(mxRGB,a),max(g,c)),i);
    mxRGB += mxRGB2;
    
    vec3 rcpMxRGB = vec3(1)/mxRGB;
    vec3 ampRGB = clamp((min(mnRGB,2.0-mxRGB) * rcpMxRGB),0,1);
    ampRGB = inversesqrt(ampRGB);
    float peak = 8.0 - 3.0 * CAS_AMOUNT;
    vec3 wRGB = -vec3(1)/(ampRGB * peak);
    vec3 rcpWeightRGB = vec3(1)/(1.0 + 4.0 * wRGB);
    vec3 window = (b + d) + (f + h);
    vec3 outColor = clamp((window * wRGB + e) * rcpWeightRGB,0,1);
    color = outColor;
}
#endif

void main() {
    vec3 color = texture2DLod(colortex1, coord0, 0).rgb;
    SharpenFilter(color, coord0);
    fragColor = vec4(color, 1.0);
}
