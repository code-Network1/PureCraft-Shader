#version 330 compatibility

uniform sampler2D colortex0;

in vec2 texcoord;

void main() {
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = texture(colortex0, texcoord);
}