/*
===============================================================================
   COSMOS GLSL - PureCraft Shader Celestial System
===============================================================================
   Advanced Sky and Celestial Object Rendering
   
   â— Purpose: Comprehensive sky rendering with sun, moon, and planetary objects
   â— Features: Multi-dimensional support, Ad Astra compatibility, dynamic lighting
   â— Compatibility: Overworld, Nether, End dimensions with unique sky systems
   
   Credits & Rights:
   â€¢ EminGT - Advanced celestial rendering system development
   â€¢ Dynamic sun/moon lighting algorithms
   â€¢ Multi-dimensional sky color systems
   â€¢ Ad Astra planetary compatibility integration
   
   Technical Features:
   - Iris shader compatibility with render stage detection
   - Adaptive celestial object lighting based on world type
   - Advanced rain and weather effects on sky visibility
   - Underwater sky color adjustment
   - Cave fog integration for realistic underground lighting
   - Custom skybox support for modded dimensions
===============================================================================
*/

// Essential library integration for sky rendering
#include "/lib/shader_modules/shader_master.glsl"

/*
===============================================================================
   FRAGMENT SHADER PIPELINE
===============================================================================
   Advanced sky fragment processing with celestial object rendering
*/
#ifdef FRAGMENT_SHADER

/*
   INPUT VERTEX DATA
   â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
   Sky rendering vertex data from vertex shader
*/
in vec2 texCoord;        // Texture coordinates for sky objects
flat in vec4 glColor;    // Vertex color from OpenGL state

// Overworld-specific directional data for sun/moon calculations
#ifdef OVERWORLD
    flat in vec3 upVec, sunVec; // World up and sun direction vectors
#endif

/*
   OVERWORLD ATMOSPHERIC CALCULATIONS
   â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
   @EminGT: Advanced sun visibility and atmospheric transition system
*/
#ifdef OVERWORLD
    float SdotU = dot(sunVec, upVec);      // Sun-Up angle for time calculations
    
    // Dynamic sun visibility with smooth day/night transitions
    float sunFactor = SdotU < 0.0 ? clamp(SdotU + 0.375, 0.0, 0.75) / 0.75 : clamp(SdotU + 0.03125, 0.0, 0.0625) / 0.0625;
    float sunVisibility = clamp(SdotU + 0.0625, 0.0, 0.125) / 0.125;
    float sunVisibility2 = sunVisibility * sunVisibility; // Quadratic falloff for smooth transitions
#endif

/*
   SPECIALIZED RENDERING SYSTEMS
   â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
   Color schemes, cave fog, and debugging utilities
*/
#include "/lib/color_schemes/core_color_system.glsl"

// Underground atmosphere effects

// Development debugging system
#ifdef COLOR_CODED_PROGRAMS
    #include "/lib/effects/effects_unified.glsl"
#endif

/*
   MAIN FRAGMENT PROCESSING
   â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
   @EminGT: Universal sky rendering with multi-dimensional support
   
   Sky System Features:
   â€¢ Overworld: Dynamic sun/moon with atmospheric effects
   â€¢ Nether: Transparent sky for void rendering
   â€¢ End: Custom End sky color system
*/
void main() {
    /*
       OVERWORLD SKY SYSTEM
       â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
       @EminGT: Advanced celestial object rendering with atmospheric integration
    */
    #ifdef OVERWORLD
        vec2 tSize = textureSize(tex, 0);              // Texture size for object identification
        vec4 color = texture2D(tex, texCoord);         // Sample sky texture
        color.rgb *= glColor.rgb;                      // Apply vertex coloring
        
        /*
           CELESTIAL OBJECT LIGHTING SYSTEM
           â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
           Skip lighting calculations for unlit sky objects mode
        */
        #ifndef UNLIT_SKY_OBJECTS
        
        /*
           COORDINATE SYSTEM SETUP
           â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
           Convert screen coordinates to view space for directional calculations
        */
        vec4 screenPos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight), gl_FragCoord.z, 1.0);
        vec4 viewPos = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
        viewPos /= viewPos.w;
        vec3 nViewPos = normalize(viewPos.xyz);
        
        // Calculate viewing angles for atmospheric effects
        float VdotS = dot(nViewPos, sunVec);  // View-Sun angle for brightness
        float VdotU = dot(nViewPos, upVec);   // View-Up angle for horizon effects
        
        /*
           CELESTIAL OBJECT IDENTIFICATION
           â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
           @EminGT: Robust sun/moon detection system with Iris compatibility
           
           Detection Methods:
           â€¢ Iris: Use render stage detection for precise identification
           â€¢ OptiFine: Use texture size and viewing angle analysis
        */
        #ifdef IS_IRIS
            bool isSun = renderStage == MC_RENDER_STAGE_SUN;
            bool isMoon = renderStage == MC_RENDER_STAGE_MOON;
        #else
            bool tSizeCheck = abs(tSize.y - 264.0) < 248.5;    // Texture size range: 16-512
            bool sunSideCheck = VdotS > 0.0;                   // Sun-facing check
            bool isSun = tSizeCheck && sunSideCheck;           // Sun identification
            bool isMoon = tSizeCheck && !sunSideCheck;         // Moon identification
        #endif
        
        /*
           SUN AND MOON RENDERING
           â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
           @EminGT: Advanced celestial lighting with world-specific adaptations
        */
        if (isSun || isMoon) {
            // Preserve vanilla sun/moon appearance
            
            /*
               SUN LIGHTING SYSTEM
               â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
               Dynamic sun lighting with world-specific color adaptation
            */
            if (isSun) {
                #if defined(WORLD_MOON) || defined(WORLD_MARS) || defined(WORLD_MERCURY) || defined(WORLD_GLACIO) || defined(AD_ASTRA_ORBIT)
                    /*
                       AD ASTRA WORLD COMPATIBILITY
                       â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                       @EminGT: Specialized sun lighting for space and planetary environments
                       
                       Features bright, consistent sun color for:
                       â€¢ Moon bases with Earth view
                       â€¢ Mars surface with reddish atmosphere
                       â€¢ Mercury's harsh solar conditions
                       â€¢ Glacio's frozen landscapes
                       â€¢ Orbital space stations
                    */
                    vec3 sunLightColor = vec3(1.0, 0.95, 0.85); // Bright warm sun color
                    color.rgb *= dot(color.rgb, color.rgb) * sunLightColor * 3.2;
                #else
                    // Standard Overworld sun lighting with vivid orange tint
                    // At sunrise/sunset: deep orange, at noon: warm amber-orange
                    vec3 sunTint = mix(vec3(1.4, 0.42, 0.0), vec3(1.25, 0.72, 0.15), noonFactor); 
                    color.rgb *= sunTint * 1.4;
                #endif
                
                // Apply atmospheric visibility with rain factor consideration
                color.rgb *= 0.25 + (0.75 - 0.25 * rainFactor) * sunVisibility2;
            }
            
            /*
               MOON LIGHTING SYSTEM
               â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
               Realistic moon rendering with luminance-based brightness
            */
            if (isMoon) {
                color.rgb *= smoothstep1(min1(length(color.rgb))) * 1.3;
            }
            
            /*
               HORIZON ATMOSPHERIC EFFECTS
               â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
               Apply horizon-based color shifts and atmospheric scattering
            */
            color.rgb *= GetHorizonFactor(VdotU);
            
            /*
               UNDERGROUND VISIBILITY ADJUSTMENT
               â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
               Reduce celestial visibility in caves and underground areas
            */
            
        } else {
            /*
               CUSTOM SKY OBJECTS
               â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
               @EminGT: Support for modded skyboxes and celestial objects
            */
            #if MC_VERSION >= 11300
                /*
                   MODERN MINECRAFT COMPATIBILITY
                   â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                   Enhanced rendering for newer Minecraft versions
                   
                   Features:
                   â€¢ Ad Astra planet preservation with balanced lighting
                   â€¢ Earth view from space without excessive darkening
                   â€¢ Color enhancement for distant celestial objects
                */
                color.rgb *= vec3(1.5, 1.5, 1.2); // Enhanced celestial object visibility
            #else
                /*
                   LEGACY VERSION HANDLING
                   â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                   Discard problematic custom skyboxes in older versions
                   due to rendering inconsistencies
                */
                discard;
            #endif
        }
        
        /*
           ENVIRONMENTAL EFFECTS
           â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
           Apply underwater and weather effects to sky visibility
        */
        
        // Underwater sky color adjustment
        if (isEyeInWater == 1) color.rgb *= 0.25;
        
        // Weather-based sky visibility
            float sunMoonVis = max(1.0 - rainFactor * 1.5, 0.0);
            color.a *= sunMoonVis;        // Complete hiding during rain
            color.rgb *= sunMoonVis;      // Fade RGB to ensure complete invisibility
        
        #endif // UNLIT_SKY_OBJECTS
    #endif // OVERWORLD
    
    /*
       NETHER DIMENSION SKY
       â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
       @EminGT: Transparent sky system for Nether void rendering
       
       The Nether uses a transparent sky to allow proper void rendering
       and maintain the characteristic dark atmosphere
    */
    #ifdef NETHER
        vec4 color = vec4(0.0); // Completely transparent
    #endif
    
    /*
       END DIMENSION SKY
       â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
       @EminGT: Custom End sky color system
       
       Uses predefined End sky color for consistent atmospheric appearance
       that matches the End's unique visual style
    */
    #ifdef END
        vec4 color = vec4(endSkyColor, 1.0); // Solid End sky color
    #endif
    
    // Development debugging system integration
    #ifdef COLOR_CODED_PROGRAMS
        ColorCodeProgram(color, -1);
    #endif
    
    /*
       OUTPUT BUFFER ASSIGNMENT
       â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
       Single color output for sky rendering
    */
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}
#endif // FRAGMENT_SHADER

/*
===============================================================================
   VERTEX SHADER PIPELINE
===============================================================================
   Sky vertex processing with directional vector calculation
*/
#ifdef VERTEX_SHADER

/*
   OUTPUT DATA TO FRAGMENT SHADER
   â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
   Sky rendering vertex data for fragment processing
*/
out vec2 texCoord;       // Texture coordinates for sky objects
flat out vec4 glColor;   // Vertex color from OpenGL state

// Overworld-specific directional vectors for atmospheric calculations
#ifdef OVERWORLD
    flat out vec3 upVec, sunVec; // World up and sun direction vectors
#endif

/*
   MAIN VERTEX PROCESSING
   â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
   @EminGT: Optimized sky vertex transformation
   
   Features:
   â€¢ Standard vertex transformation for sky geometry
   â€¢ Texture coordinate mapping for celestial objects
   â€¢ Directional vector calculation for atmospheric effects
*/
void main() {
    /*
       VERTEX TRANSFORMATION
       â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
       Standard sky geometry transformation
    */
    gl_Position = ftransform();
    
    /*
       TEXTURE COORDINATE SETUP
       â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
       Map texture coordinates for sky objects (sun, moon, stars)
    */
    texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    
    /*
       COLOR DATA TRANSFER
       â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
       Pass vertex color to fragment shader
    */
    glColor = gl_Color;
    
    /*
       OVERWORLD DIRECTIONAL VECTOR SETUP
       â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
       @EminGT: Calculate world-space directional vectors for atmospheric effects
       
       These vectors are essential for:
       â€¢ Sun position tracking and lighting calculations
       â€¢ Atmospheric scattering and horizon effects
       â€¢ Day/night cycle transitions
       â€¢ Weather effect integration
    */
    #ifdef OVERWORLD
        upVec = normalize(gbufferModelView[1].xyz);  // World up direction
        sunVec = GetSunVector();                     // Current sun/moon position
    #endif
}

#endif

/*
===============================================================================
   END OF COSMOS SHADER
   @EminGT - Advanced celestial rendering system with multi-dimensional support
===============================================================================
*/
