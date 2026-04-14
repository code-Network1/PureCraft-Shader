#version 130

#define FRAGMENT_SHADER
#define OVERWORLD
#define GBUFFERS_CLOUDS

#include "/lib/shader_modules/shader_master.glsl"

in vec2 texcoord;
in vec4 glcolor;
in float cylindricalDist;

void main() {
    // Base vanilla cloud texture
    vec4 color = texture2D(tex, texcoord);
    color.a *= glcolor.a; // Keep vanilla opacity fading

    // ═════════════════════════════════════════════════════════════════════════
    //                     HORIZON SCATTERING (SMOOTH EDGES)
    // ═════════════════════════════════════════════════════════════════════════
    // The built-in 'far' variable is natively broken/shrunk during the clouds pass.
    // We bypass it completely by using the actual user 'renderDistance' uniform!
    // 1 chunk = 16 blocks. We calculate the absolute true horizon distance.
    float trueHorizon = float(renderDistance) * 16.0;
    
    // Smoothly dissolve clouds into the sky starting extremely early (at 20% to the horizon),
    // and completely vanish them by 70%. We MUST vanish them before they reach 100% 
    // horizon because the game's engine natively 'cuts off' the physical geometry blocks.
    // Fading them fully before that cutoff guarantees the edges will never look sharp!
    float horizonFade = 1.0 - smoothstep(trueHorizon * 0.20, trueHorizon * 0.70, cylindricalDist);
    
    color.a *= horizonFade;
    
    // Calculate custom dynamic color using shader_master time variables
    vec3 noonColor = vec3(0.95, 0.97, 1.0); // Noon
    
    // Sunset: Two colors based on side, absolutely NO 3D shading baked in 
    vec3 sunsetBase = vec3(0.45, 0.45, 0.50); // Dark grey/silver for the sides facing away
    vec3 sunsetOrange = vec3(1.3, 0.65, 0.2); // Warm sunset colors for sun-facing edges
    
    // We use glcolor.r just as a directional mask (1.0 = sun facing, lower = shaded side)
    // but we WILL NOT multiply the final color by glcolor.rgb to keep them flat.
    float sunFacing = step(0.85, glcolor.r); 
    vec3 currentSunsetColor = mix(sunsetBase, sunsetOrange, sunFacing);
    
    float extendedSunsetMix = sqrt(max(invNoonFactor, 0.0)); 
    
    // Transition from noon to two-toned sunset
    vec3 cloudColor = mix(noonColor, currentSunsetColor, extendedSunsetMix * (1.0 - nightFactor));
    
    // Night clouds — Dark natural grey (not black!)
    vec3 nightColor = vec3(0.28, 0.30, 0.35); // Lighter dark grey so they are visible
    cloudColor = mix(cloudColor, nightColor, nightFactor);
    
    // Monolithic grey rain
    vec3 rainColor = vec3(0.35, 0.38, 0.42);
    cloudColor = mix(cloudColor, rainColor, rainFactor);
    
    // Apply final lighting logic (Removed glcolor.rgb to make them FLAT 2D style)
    color.rgb *= cloudColor * 2.0;

    /* DRAWBUFFERS:063 */
    gl_FragData[0] = color;
    gl_FragData[1] = vec4(0.0, 0.0, 0.0, 1.0);
    gl_FragData[2] = vec4(1.0 - color.rgb, color.a);
}
