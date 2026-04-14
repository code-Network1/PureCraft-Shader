#version 130

#define VERTEX_SHADER
#define OVERWORLD
#define GBUFFERS_CLOUDS

#include "/lib/shader_modules/shader_master.glsl"

// Simple pass-through for vanilla clouds
// Simple pass-through for vanilla clouds
out vec2 texcoord;
out vec4 glcolor;
out float cylindricalDist;

void main() {
    // Base object-space vertex
    vec4 position = gl_Vertex;
    float time = frameTimeCounter;

    // ═════════════════════════════════════════════════════════════════════════
    //                     SUBTLE CLOTH PHYSICS & SCROLLING
    vec4 animatedVertex = position;

    // 1. Idle Cloth Animation
    // Effect reduced significantly so it is just a very light, almost imperceptible atmospheric drift rather than a massive wobble.
    float gentleClothY = sin(position.x * 0.015 + time * 1.0) * 0.8 + cos(position.z * 0.012 + time * 0.8) * 0.5;
    animatedVertex.y += gentleClothY;

    // Output mapped coordinates
    gl_Position = gl_ModelViewProjectionMatrix * animatedVertex;
    
    // Calculate True World Space Distance from the player (ignoring cloud height & camera rotation)
    // We convert the view-space vertex back to world-space so rotation (pitch/yaw) doesn't warp the XZ distance!
    vec4 eyePos = gl_ModelViewMatrix * animatedVertex;
    vec3 worldPos = (gbufferModelViewInverse * eyePos).xyz;
    cylindricalDist = length(worldPos.xz);
    
    // Base texture coordinates
    vec2 baseTexCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    
    // 2. Infinite Forward Movement (Loop)
    // Speed heavily increased to make the clouds clearly race forward across the sky 
    float fastWindSpeed = time * 0.015; 
    baseTexCoord.x -= fastWindSpeed;
    
    texcoord = baseTexCoord;
    glcolor = gl_Color;
}
