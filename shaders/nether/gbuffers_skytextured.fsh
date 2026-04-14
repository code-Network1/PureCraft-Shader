#version 330 compatibility

uniform sampler2D gtexture;

in vec2 texcoord;
in vec4 glcolor;

void main() {
    vec4 color = texture(gtexture, texcoord) * glcolor;

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}