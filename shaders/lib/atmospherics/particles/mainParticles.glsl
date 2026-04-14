/*
 * MAIN PARTICLES SYSTEM
 * Copyright (c) 2025 EminGT
 */

#ifdef ATM_COLOR_MULTS
    #include "/lib/color_schemes/color_effects_system.glsl"
#endif
#ifdef MOON_PHASE_INF_ATMOSPHERE
    #include "/lib/color_schemes/color_effects_system.glsl"
#endif

// Border fog system

// Cave fog system

//═══════════════════════════════════════════════════════════════════════════════════════
//                            ATMOSPHERIC FOG SYSTEM MODULE
//═══════════════════════════════════════════════════════════════════════════════════════

// Liquid fog effects
#include "/lib/atmospherics/particles/liquidEffects.glsl"

void DoWaterFog(inout vec3 color, float lViewPos) {
    float fog = GetWaterFog(lViewPos);
    color = mix(color, waterFogColor, fog);
}

void DoLavaFog(inout vec3 color, float lViewPos) {
    float fog = (lViewPos * 3.0 - gl_Fog.start) * gl_Fog.scale;

    #ifdef LESS_LAVA_FOG
        fog = sqrt(fog) * 0.4;
    #endif

    fog = 1.0 - exp(-fog);
    fog = clamp(fog, 0.0, 1.0);
    color = mix(color, fogColor * 5.0, fog);
}

void DoPowderSnowFog(inout vec3 color, float lViewPos) {
    float fog = lViewPos;

    #ifdef LESS_LAVA_FOG
        fog = sqrt(fog) * 0.4;
    #endif

    fog *= fog;
    fog = 1.0 - exp(-fog);
    fog = clamp(fog, 0.0, 1.0);
    color = mix(color, fogColor, fog);
}

void DoBlindnessFog(inout vec3 color, float lViewPos) {
    float fog = lViewPos * 0.3 * blindness;
    fog *= fog;
    fog = 1.0 - exp(-fog);
    fog = clamp(fog, 0.0, 1.0);
    color = mix(color, vec3(0.0), fog);
}

void DoDarknessFog(inout vec3 color, float lViewPos) {
    float fog = lViewPos * 0.075 * darknessFactor;
    fog *= fog;
    fog *= fog;
    color *= exp(-fog);
}

void DoRainGroundMist(inout vec3 color, vec3 playerPos, float lViewPos, float dither) {
    // Logic relocated to deferred1.glsl for precise per-pixel roof detection via skylight.
}

// Main fog processor
void DoFog(inout vec3 color, inout float skyFade, float lViewPos, vec3 playerPos, float VdotU, float VdotS, float dither) {
    
    

    if (isEyeInWater == 1) DoWaterFog(color, lViewPos);
    else if (isEyeInWater == 2) DoLavaFog(color, lViewPos);
    else if (isEyeInWater == 3) DoPowderSnowFog(color, lViewPos);

    if (blindness > 0.00001) DoBlindnessFog(color, lViewPos);
    if (darknessFactor > 0.00001) DoDarknessFog(color, lViewPos);
    
    // Apple the new rain mist exclusively during rainy weather
    DoRainGroundMist(color, playerPos, lViewPos, dither);
}

// Legacy compatibility
#define GetMainFog DoFog
#define ProcessAtmosphericEffects DoFog
