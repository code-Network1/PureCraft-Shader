#version 330 compatibility

uniform sampler2D gtexture;
uniform sampler2D lightmap;

in vec2 texcoord;
in vec2 lmcoord;
in vec4 glcolor;

void main() {
    vec4 color = texture(gtexture, texcoord) * glcolor;
    if (color.a < 0.1) discard;
    color *= texture(lightmap, lmcoord);

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}