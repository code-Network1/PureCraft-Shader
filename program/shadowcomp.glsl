/* 
PureCraft Shader - Created by EminGT
// Modified by Haider
Shadow Composite Pass
*/ 

//Settings//
#include "../lib/shader_config.glsl"

//Fragment Shader///////////////////////////////////////////////////////////////////////////////////
#ifdef FSH

//Varyings//
varying vec2 texCoord;

//Uniforms//
uniform sampler2D colortex0;

//Program//
void main() {
    vec3 color = texture2D(colortex0, texCoord).rgb;
    
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, 1.0);
}

#endif

//Vertex Shader/////////////////////////////////////////////////////////////////////////////////////
#ifdef VSH

//Varyings//
varying vec2 texCoord;

//Program//
void main() {
    gl_Position = ftransform();
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif
