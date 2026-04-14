/*
 * CORE COLOR SYSTEM
 * Copyright (c) 2025 EminGT
 */

#ifndef INCLUDE_SKY_COLORS
    #define INCLUDE_SKY_COLORS

    #if defined OVERWORLD
        // Sky Color Processing
        vec3 skyColorSqrt = sqrt(skyColor);
        
        // Thunderstorm protection
        float invRainStrength2 = (1.0 - rainStrength) * (1.0 - rainStrength);
        vec3 skyColorM = mix(max(skyColorSqrt, vec3(0.63, 0.67, 0.73)), skyColorSqrt, invRainStrength2);
        vec3 skyColorM2 = mix(max(skyColor, sunFactor * vec3(0.265, 0.295, 0.35)), skyColor, invRainStrength2);

        /**
         * Biome-Specific Weather Modifiers
         * Adjusts sky colors based on local environmental conditions
         */
        
        /**
         * Advanced Rain Style Color Modifications
         * Style 2: Enhanced precipitation color effects
         */
        #if RAIN_STYLE == 2
            vec3 nmscRainMP = vec3(-0.15, 0.025, 0.1);
            vec3 ndscRainMP = vec3(-0.125, -0.005, 0.125);
        #else
            vec3 nmscRainM = vec3(0.0), ndscRainM = vec3(0.0);
        #endif
        
        // Weather color modifiers
        vec3 nmscWeatherM = vec3(-0.1, -0.4, -0.6) + vec3(0.0, 0.06, 0.12) * noonFactor;
        vec3 ndscWeatherM = vec3(-0.15, -0.3, -0.42) + vec3(0.0, 0.02, 0.08) * noonFactor;

        // ═══════════════════════════════════════════════════════════════════
        //  CINEMATIC SKY — AAA-quality dynamic sky gradients
        //  Each time of day has a unique, dramatic atmosphere
        // ═══════════════════════════════════════════════════════════════════

        // ── NOON: Deep clear cerulean blue — bright and vivid ──
        vec3 noonUpSkyColor     = pow(skyColorM, vec3(2.8)) * vec3(0.30, 0.38, 0.88)
                                + vec3(0.003, 0.008, 0.048);
        vec3 noonMiddleSkyColor = pow(skyColorM, vec3(1.0)) * (vec3(0.58, 0.70, 1.02) + rainFactor * (nmscWeatherM + nmscRainM))
                                + vec3(0.015, 0.030, 0.055);
        vec3 noonDownSkyColor   = skyColorM * (vec3(0.84, 0.88, 0.78) + rainFactor * (ndscWeatherM + ndscRainM))
                                + vec3(0.040, 0.038, 0.028);

        // ── SUNSET/SUNRISE: Cinematic golden hour — dramatic warm sky ──
        vec3 sunsetUpSkyColor     = skyColorM2 * (vec3(0.48, 0.25, 0.58) + vec3(0.04, 0.06, 0.10) * rainFactor2)
                                  + vec3(0.040, 0.018, 0.055);
        vec3 sunsetMiddleSkyColor = skyColorM2 * (vec3(0.95, 0.48, 0.25) + vec3(0.03, 0.08, -0.04) * rainFactor2)
                                  + vec3(0.060, 0.028, 0.006);
        vec3 sunsetDownSkyColorP  = vec3(1.20, 0.55, 0.10) - vec3(0.42, 0.20, 0.0) * rainFactor;
        vec3 sunsetDownSkyColor   = sunsetDownSkyColorP * 0.55 + 0.25 * sunsetMiddleSkyColor
                                  + vec3(0.045, 0.015, 0.0);

        // ── RAIN: Moody grey overcast ──
        vec3 rainSkyColor = vec3(0.34, 0.35, 0.40);

        // ── DAY BLEND ──
        vec3 dayUpSkyColor      = mix(mix(noonUpSkyColor,     sunsetUpSkyColor,     invNoonFactor2), rainSkyColor, rainFactor);
        vec3 dayMiddleSkyColor  = mix(mix(noonMiddleSkyColor, sunsetMiddleSkyColor, invNoonFactor2), rainSkyColor * 1.05, rainFactor);
        vec3 dayDownSkyColor    = mix(mix(noonDownSkyColor,   sunsetDownSkyColor,   invNoonFactor2), rainSkyColor * 1.10, rainFactor);

        // ── NIGHT: Deep enchanting sky — moonlit atmosphere with star visibility ──
        float nrScale = 1.0 + 1.2 * rainFactor;
        vec3 nightColFactor      = vec3(0.04, 0.05, 0.15) * (1.0 - 0.30 * rainFactor);
        vec3 nightUpSkyColor     = pow(nightColFactor, vec3(0.80)) * 0.09 * nrScale
                                 + vec3(0.0008, 0.0012, 0.0060);
        vec3 nightMiddleSkyColor = sqrt(nightUpSkyColor) * 0.20 * nrScale
                                 + vec3(0.0012, 0.0018, 0.0055);
        vec3 nightDownSkyColor   = nightMiddleSkyColor * vec3(0.88, 0.85, 0.80) * nrScale
                                 + vec3(0.0018, 0.0018, 0.0025);
    #endif

#endif //INCLUDE_SKY_COLORS

// Lighting & Ambient Color System
#ifndef INCLUDE_LIGHT_AND_AMBIENT_COLORS
    #define INCLUDE_LIGHT_AND_AMBIENT_COLORS

    #if defined OVERWORLD
        
        // ═══════════════════════════════════════════════════════════════════
        //  CINEMATIC LIGHTING — Dynamic, immersive, AAA-quality
        //  Each time of day has its own distinct visual identity
        // ═══════════════════════════════════════════════════════════════════

        // ── NOON: Warm-neutral white sunlight — clean, bright, natural ──
        #ifndef COMPOSITE
            vec3 noonClearLightColor = vec3(0.60, 0.57, 0.48) * 0.95;
        #else
            vec3 noonClearLightColor = vec3(0.58, 0.55, 0.46);
        #endif
        vec3 noonClearAmbientColor = pow(skyColor, vec3(0.55)) * 0.62
                                   + vec3(0.005, 0.006, 0.012);

        // ── SUNSET/SUNRISE: Rich golden-orange light — cinematic golden hour ──
        #ifndef COMPOSITE
            vec3 sunsetClearLightColor = pow(vec3(0.85, 0.40, 0.12), vec3(1.15 + invNoonFactor)) * 4.5;
        #else
            vec3 sunsetClearLightColor = pow(vec3(0.82, 0.38, 0.10), vec3(1.15 + invNoonFactor)) * 4.8;
        #endif
        vec3 sunsetClearAmbientColor = noonClearAmbientColor * vec3(1.25, 0.80, 0.55) * 0.82
                                     + vec3(0.015, 0.008, 0.003);

        // ── NIGHT: Silver-blue moonlight — enchanting and mystical ──
        #if !defined COMPOSITE && !defined DEFERRED1
            vec3 nightClearLightColor = vec3(0.14, 0.17, 0.32) * (0.65 + vsBrightness * 0.40);
        #elif defined DEFERRED1
            vec3 nightClearLightColor = vec3(0.11, 0.13, 0.26);
        #else
            vec3 nightClearLightColor = vec3(0.10, 0.12, 0.24);
        #endif
        vec3 nightClearAmbientColor = vec3(0.038, 0.045, 0.080) * (1.15 + vsBrightness * 0.50)
                                    + vec3(0.002, 0.002, 0.004);

        // Biome-specific lighting modifiers
        
        // Rain lighting
        #if RAIN_STYLE == 2
            vec3 drlcRainMP = vec3(-0.03, 0.0, 0.02);
        #else
            vec3 drlcRainM = vec3(0.0);
        #endif

        // Rainy weather lighting — muted overcast atmosphere
        vec3 dayRainLightColor = vec3(0.14, 0.14, 0.16) * 0.80
                               + rainFactor * drlcRainM;
        vec3 dayRainAmbientColor = vec3(0.20, 0.21, 0.24) * (1.55 + 0.40 * vsBrightness);

        vec3 nightRainLightColor = vec3(0.05, 0.05, 0.07) * (0.65 + 0.30 * vsBrightness);
        vec3 nightRainAmbientColor = vec3(0.06, 0.06, 0.08) * (1.05 + 0.35 * vsBrightness);

        // Color blending
        #ifndef COMPOSITE
            float noonFactorDM = noonFactor * noonFactor;
        #else
            float noonFactorDM = noonFactor * noonFactor;
        #endif
        
        vec3 dayLightColor = mix(sunsetClearLightColor, noonClearLightColor, noonFactorDM);
        vec3 dayAmbientColor = mix(sunsetClearAmbientColor, noonClearAmbientColor, noonFactorDM);

        vec3 clearLightColor = mix(nightClearLightColor, dayLightColor, sunVisibility2);
        vec3 clearAmbientColor = mix(nightClearAmbientColor, dayAmbientColor, sunVisibility2);

        vec3 rainLightColor = mix(nightRainLightColor, dayRainLightColor, sunVisibility2) * 2.5;
        vec3 rainAmbientColor = mix(nightRainAmbientColor, dayRainAmbientColor, sunVisibility2);

        vec3 lightColor = mix(clearLightColor, rainLightColor, rainFactor);
        vec3 ambientColor = mix(clearAmbientColor, rainAmbientColor, rainFactor);
        
    #elif defined NETHER
        // Nether lighting
        vec3 lightColor = vec3(0.0);
        vec3 ambientColor = (netherColor + 0.5 * lavaLightColor) * (0.30 + 0.20 * vsBrightness);
        
    #elif defined END
        // End lighting
        vec3 endLightColor = vec3(0.68, 0.51, 1.07);
        float endLightBalancer = 0.2 * vsBrightness;
        
        vec3 lightColor = endLightColor * (0.35 - endLightBalancer);
        vec3 ambientColor = endLightColor * (0.2 + endLightBalancer);
    #endif

#endif //INCLUDE_LIGHT_AND_AMBIENT_COLORS

// Cloud Color System
#ifndef INCLUDE_CLOUD_COLORS
    #define INCLUDE_CLOUD_COLORS

    #if defined OVERWORLD
        // ── CLOUD COLORS: Match fantasy sky palette and weather conditions ──
        vec3 cloudRainColor = mix(nightMiddleSkyColor, dayMiddleSkyColor, sunFactor);

        // Sunset cloud tint — rich golden warmth
        vec3 sunsetCloudTint = vec3(1.18, 0.85, 0.60);

        // Cloud ambient: derives from scene ambient — moonlit at night
        vec3 cloudAmbientColor = mix(
            ambientColor * (sunVisibility2 * (0.55 + 0.15 * noonFactor) + 0.15)
            + nightClearLightColor * (1.0 - sunVisibility2) * 0.45,
            vec3(0.25, 0.26, 0.28),
            rainFactor
        );

        // Cloud direct light: natural warm tint at sunset, neutral otherwise
        vec3 cloudLightColor = mix(
            mix(lightColor * (0.90 + 0.20 * noonFactor), lightColor * (0.90 + 0.20 * noonFactor) * sunsetCloudTint, invNoonFactor2),
            vec3(0.28, 0.30, 0.32),
            rainFactor
        );
    #else
        // Non-overworld dimension cloud colors
        vec3 cloudRainColor = vec3(0.4, 0.3, 0.3);
        vec3 cloudAmbientColor = ambientColor * 0.7;
        vec3 cloudLightColor = lightColor * 0.8;
    #endif

#endif //INCLUDE_CLOUD_COLORS
