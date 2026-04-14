/*
ATMOSPHERIC HORIZON MODULE
Copyright (c) 2025 EminGT
*/

#ifndef INCLUDE_ATMOSPHERIC_HORIZON
#define INCLUDE_ATMOSPHERIC_HORIZON

#include "/lib/color_schemes/core_color_system.glsl"

vec3 GetSkyHorizon(float VdotU, float VdotS, float dither, bool doGlare, bool doGround) {
    float nightFactorSqrt2 = sqrt2(nightFactor);
    float nightFactorM = sqrt2(nightFactorSqrt2) * 0.4;
    
    float VdotSM1 = pow2(max(VdotS, 0.0));
    float VdotSM2 = pow2(VdotSM1);
    float VdotSM3 = pow2(pow2(max(-VdotS, 0.0)));
    float VdotSML = sunVisibility > 0.5 ? VdotS : -VdotS;
    
    float VdotUmax0  = max(VdotU, 0.0);
    float VdotUmax0M = 1.0 - pow2(VdotUmax0);

    // ── SKY GRADIENT: Zenith → Middle → Horizon (rich full-sky gradient) ──
    float nightVsh = pow2(1.0 - sunFactor); // Makes night sky vanish non-linearly to prevent purple mix
    vec3 upColor = 
        nightUpSkyColor * nightVsh * (0.60 - 0.15 * nightFactorSqrt2 + nightFactorM * VdotSM3 * 0.5)
        + dayUpSkyColor * sunFactor;
    
    vec3 middleColor = 
        nightMiddleSkyColor * nightVsh * (1.20 - 0.60 * nightFactorSqrt2)
        + dayMiddleSkyColor * sunFactor * (1.0 + VdotSM2 * 0.5);
    
    // Inject warm glow only during sunrise/sunset transitions (not into full sky)
    float purpleKiller = sunFactor * (1.0 - sunFactor) * 4.0;
    vec3 warmTransitionGlow = vec3(0.14, 0.065, 0.012) * purpleKiller * invRainFactor;
    upColor += warmTransitionGlow * 0.22;
    middleColor += warmTransitionGlow * 0.50;
    
    // Very subtle horizon warmth during afternoon transitions only
    float afternoonWarmth = sunFactor * pow2(1.0 - noonFactor * 0.6) * invRainFactor;
    upColor += vec3(0.003, 0.002, 0.001) * afternoonWarmth;
    middleColor += vec3(0.008, 0.005, 0.002) * afternoonWarmth;

    vec3 downColor = mix(
        nightDownSkyColor,
        dayDownSkyColor,
        (sunFactor + sunVisibility) * 0.5
    );

    // Zenith → midsky gradient (enhanced full-sky gradient with stronger color spread)
    float VdotUM1 = pow2(1.0 - VdotUmax0);
    VdotUM1 = pow(VdotUM1, 1.0 - VdotSM2 * 0.45);  // Stronger sun influence on gradient
    VdotUM1 = mix(VdotUM1, 1.0, 0.12 + rainFactor2 * 0.15); // Softening for gradient visibility
    vec3 finalSky = mix(upColor, middleColor, VdotUM1);

    // ── HORIZON BAND: Warm glow at horizon during sunrise/sunset ──
    float VdotUM2 = pow2(1.0 - abs(VdotU));
    VdotUM2 = VdotUM2 * VdotUM2 * (3.0 - 2.0 * VdotUM2);
    float horizonGate = max(invNoonFactor, 0.15) * sunFactor; // Reduced at noon — gradient mostly during sunrise/sunset
    VdotUM2 *= (0.80 - nightFactorM + VdotSM1 * (0.40 + nightFactorM)) * horizonGate;
    finalSky = mix(finalSky, sunsetDownSkyColorP * (1.0 + VdotSM1 * 0.50), VdotUM2 * 0.82 * invRainFactor);
    
    // Very subtle warm horizon tint at noon (barely visible natural scatter)
    float noonWarmHorizon = noonFactor * sunFactor * invRainFactor;
    float horizonBlend = pow2(1.0 - abs(VdotU)) * pow2(1.0 - abs(VdotU));
    finalSky += vec3(0.008, 0.006, 0.003) * horizonBlend * noonWarmHorizon;

    // ── GROUND SCATTER: Below-horizon atmospheric color ──
    float VdotUM3 = min(max0(-VdotU + 0.08) / 0.35, 1.0);
    VdotUM3 = smoothstep1(VdotUM3);
    vec3 scatteredGroundMixer = vec3(VdotUM3 * VdotUM3, sqrt1(VdotUM3), sqrt3(VdotUM3));
    scatteredGroundMixer = mix(vec3(VdotUM3), scatteredGroundMixer, 0.65 - 0.4 * rainFactor);
    finalSky = mix(finalSky, downColor, scatteredGroundMixer);

    if (doGround) {
        finalSky *= smoothstep1(pow2(1.0 + min(VdotU, 0.0)));
    }

    if (isEyeInWater == 1) {
        finalSky = mix(finalSky * 3.0, waterFogColor, VdotUmax0M);
    }

    // ── SUN & MOON GLARE: Subtle warm glow — sun disc must remain visible ──
    #if !(defined(DISABLE_UNBOUND_SUN_MOON) && (SUN_MOON_STYLE >= 2))
    if (doGlare && 0.0 < VdotSML) {
        float glareScatter = 4.0 * (2.0 - clamp01(VdotS * 1000.0));
        float VdotSM4 = pow(abs(VdotS), glareScatter);

        float visfactor = 0.082;
        float glare = visfactor / (1.0 - (1.0 - visfactor) * VdotSM4) - visfactor;

        // Greatly reduced glare so sun disc shape is visible
        glare *= 0.025 + pow2(noonFactor) * 0.035; 
        glare *= 1.0 - rainFactor * 0.5;
        
        // Tight cap to prevent any white-out
        glare = min(glare, 0.12); 
        
        // Wide core hole to reveal the square sun disc clearly
        float sunCoreHole = smoothstep(0.996, 1.0, abs(VdotS));
        glare *= 1.0 - sunCoreHole * 0.98; // Cuts 98% of glare over the sun disc

        float glareWaterFactor = isEyeInWater * sunVisibility;
        
        vec3 sunGlareColor = mix(vec3(1.05, 0.48, 0.08), vec3(0.96, 0.80, 0.45), noonFactor);
        vec3 moonGlareColor = vec3(0.10, 0.12, 0.24);
        vec3 glareColor = mix(sunGlareColor, moonGlareColor, nightFactor);
        
        glareColor = glareColor + glareWaterFactor * vec3(7.0);

        finalSky += glare * shadowTime * glareColor;
    }
    #endif

    // Clean sky output — no color tinting
    finalSky += (dither - 0.5) / 128.0;

    return finalSky;
}

vec3 GetOptimizedSkyHorizon(float VdotU, float VdotS, float dither, bool doGlare, bool doGround) {
    float VdotUmax0  = max(VdotU, 0.0);
    float VdotUmax0M = 1.0 - pow2(VdotUmax0);

    float nightVsh = pow2(1.0 - sunFactor);
    vec3 upColor     = nightUpSkyColor * nightVsh * 0.60 + dayUpSkyColor * sunFactor;
    vec3 middleColor = nightMiddleSkyColor * nightVsh * 0.80 + dayMiddleSkyColor * sunFactor;
    
    float purpleKiller = sunFactor * (1.0 - sunFactor) * 4.0;
    vec3 warmTransitionGlow = vec3(0.10, 0.045, 0.010) * purpleKiller * invRainFactor;
    upColor += warmTransitionGlow * 0.35;
    middleColor += warmTransitionGlow * 0.70;

    float VdotUM1 = pow2(1.0 - VdotUmax0);
    VdotUM1 = mix(VdotUM1, 1.0, rainFactor2 * 0.2);
    vec3 finalSky = mix(upColor, middleColor, VdotUM1);

    float VdotSM1 = pow2(max(VdotS, 0.0));
    float VdotUM2 = pow2(1.0 - abs(VdotU));
    VdotUM2 *= max(invNoonFactor, 0.15) * sunFactor * (0.85 + 0.20 * VdotS);
    finalSky = mix(finalSky, sunsetDownSkyColorP * (shadowTime * 0.65 + 0.22), VdotUM2 * invRainFactor);

    // Subtle noon horizon
    float noonHorizonOpt = noonFactor * sunFactor * invRainFactor;
    float hBlendOpt = pow2(1.0 - abs(VdotU)) * pow2(1.0 - abs(VdotU));
    finalSky += vec3(0.012, 0.010, 0.005) * hBlendOpt * noonHorizonOpt;

    finalSky *= pow2(pow2(1.0 + min(VdotU, 0.0)));

    if (isEyeInWater == 1) {
        finalSky = mix(finalSky * 3.0, waterFogColor, VdotUmax0M);
    }

    #if !(defined(DISABLE_UNBOUND_SUN_MOON) && (SUN_MOON_STYLE >= 2))
    float glareMult = mix(nightFactor, 0.5 + 0.7 * noonFactor, VdotS * 0.5 + 0.5) * pow2(pow2(pow2(pow2(VdotS))));
    glareMult *= 0.06; // Very low intensity
    float sunCoreHoleOpt = smoothstep(0.996, 1.0, abs(VdotS));
    glareMult *= 1.0 - sunCoreHoleOpt * 0.98;
    vec3 optGlareColor = mix(vec3(1.05, 0.48, 0.08), vec3(0.96, 0.80, 0.45), noonFactor);
    optGlareColor = mix(optGlareColor, vec3(0.12, 0.14, 0.25), nightFactor);
    finalSky += optGlareColor * glareMult * 1.5; 
    #endif

    // Subtle warm vibrance filter at noon (artistic continuity with sunrise)
    float warmVibranceMixOpt = noonFactor * sunFactor * invRainFactor * 0.03;
    finalSky = mix(finalSky, finalSky * vec3(1.03, 1.01, 0.96), warmVibranceMixOpt);

    return finalSky;
}

#define GetSky GetSkyHorizon
#define GetLowQualitySky GetOptimizedSkyHorizon

#endif // INCLUDE_ATMOSPHERIC_HORIZON
