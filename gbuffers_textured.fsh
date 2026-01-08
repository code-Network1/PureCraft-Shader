#version 120
uniform sampler2D texture;
uniform sampler2D lightmap;
uniform vec4 entityColor;
uniform int fogMode;
const int GL_LINEAR = 9729;
const int GL_EXP = 2048;
uniform int isEyeInWater;
varying vec4 color;
varying vec2 coord0;
varying vec2 coord1;

void main() {    
    vec4 col = color * texture2D(lightmap,coord1) * texture2D(texture,coord0);
    col.rgb = mix(col.rgb,entityColor.rgb,entityColor.a);
    if(fogMode == GL_LINEAR){
        float fog = clamp((gl_FogFragCoord-gl_Fog.start) * gl_Fog.scale, 0., 1.);		
        col.rgb = mix(col.rgb, gl_Fog.color.rgb, fog);
    } else if(fogMode == GL_EXP || isEyeInWater >= 1){
        float fog = 1.-clamp(exp(-gl_FogFragCoord * gl_Fog.density), 0., 1.);
        col.rgb = mix(col.rgb, gl_Fog.color.rgb, fog);
    }
    /*DRAWBUFFERS:0*/
    gl_FragData[0] = col;
}
