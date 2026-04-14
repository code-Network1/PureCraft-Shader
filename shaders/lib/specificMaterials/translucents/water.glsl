// ============================== Step 1: Color Prep ============================== //
#if defined GBUFFERS_WATER || defined DH_WATER
    translucentMultCalculated = true;
    translucentMult.rgb = normalize(sqrt2(glColor.rgb));
    translucentMult.g *= 0.88;

    // brighter and more natural water colors
    vec3 dayColor    = vec3(0.15, 0.4, 0.65);
    vec3 sunsetColor = vec3(0.4, 0.25, 0.2);
    vec3 nightColor  = vec3(0.08, 0.15, 0.25); // Brighter than before so it doesn't turn pitch black

    vec3 baseColor = mix(nightColor, dayColor, sunVisibility);
    float sunsetBlend = (1.0 - shadowTimeVar1);
    baseColor = mix(baseColor, sunsetColor, sunsetBlend * 0.6);

    // Keep the vanilla texture but blend it gently with the environment lighting
    vec3 texColor = colorP.rgb * glColor.rgb * 1.5; // Slightly boosted texture color
    
    // A much more vibrant mix
    color.rgb = mix(baseColor, texColor, 0.5);
#endif

#ifdef WATERCOLOR_CHANGED
    color.rgb *= vec3(WATERCOLOR_RM, WATERCOLOR_GM, WATERCOLOR_BM);
#endif
// ============================== End of Step 1 ============================== //

#if defined GBUFFERS_WATER || defined DH_WATER
    lmCoordM.y = min(lmCoord.y * 1.07, 1.0); // Iris/Sodium skylight inconsistency workaround
    
    float fresnel2 = pow2(fresnel);
    float fresnel4 = pow2(fresnel2);

    // ============================== Step 2: Water Normals (Reflectify RT Edition) ============================== //
    reflectMult = 1.0; 

    #if WATER_MAT_QUALITY >= 3
        materialMask = OSIEBCA * 241.0; // Water
    #endif

    vec2 worldXZ = playerPos.xz + cameraPosition.xz;
    float time = frameTimeCounter;
    float camDist = lViewPos;
    float scale = 1.0;
    float amp = 0.25;
    float steep = 1.0;
    float spd = 1.0 * 0.4;
    
    float lod0 = 1.0;
    float lod1 = 1.0 - smoothstep(16.0, 64.0, camDist);
    float lod2 = 1.0 - smoothstep(8.0, 24.0, camDist);
    
    vec3 wNorm = vec3(0.0);

    // inline Gerstner calculation
    #define GERSTNER_F(wDir, wLen, wAmp, wSteep, phaseSpeed) \
    { \
        float k = 6.28318530718 / (wLen); \
        float c = sqrt(9.8 / k); \
        float phase = k * dot(wDir, worldXZ) - c * (phaseSpeed); \
        float Q = (wSteep) / (k * (wAmp) * 4.0); \
        float cosP = cos(phase); \
        float sinP = sin(phase); \
        wNorm += vec3(-(wDir).x * k * (wAmp) * cosP, -Q * k * (wAmp) * sinP, -(wDir).y * k * (wAmp) * cosP); \
    }

    GERSTNER_F(normalize(vec2(1.0, 0.6)), 6.0*scale, amp*1.0, steep, time*spd);
    wNorm *= lod0;
    vec3 n1 = vec3(0.0);
    GERSTNER_F(normalize(vec2(0.2, 1.0)), 2.5*scale, amp*0.35, steep*0.5, time*spd*1.4);
    wNorm += n1 * lod1;
    
#if WATER_STYLE == 1
    normal = normalize(normal + wNorm);
    normalM = normal;
#else
    normalM = normalize(normal + wNorm);
#endif

    // Re-evaluate fresnel with new normal
    fresnel = clamp(1.0 + dot(normalM, nViewPos), 0.0, 1.0);
    fresnel2 = pow2(fresnel);
    fresnel4 = pow2(fresnel2);

    // ============================== End of Step 2 ============================== //

    // ============================== Step 3: Water Material Features (Simplified) ============================== //
    #if WATER_MAT_QUALITY >= 2
        if (isEyeInWater != 1) {
            // Simple vanilla-like water alpha
            #ifdef GBUFFERS_WATER
                float depthT = texelFetch(depthtex1, texelCoord, 0).r;
            #elif defined DH_WATER
                float depthT = texelFetch(dhDepthTex1, texelCoord, 0).r;
            #endif
            vec3 screenPosT = vec3(screenPos.xy, depthT);
            #ifdef TAA
                vec3 viewPosT = ScreenToView(vec3(TAAJitter(screenPosT.xy, -0.5), screenPosT.z));
            #else
                vec3 viewPosT = ScreenToView(screenPosT);
            #endif
            float lViewPosT = length(viewPosT);
            float lViewPosDifM = lViewPos - lViewPosT;

            // Full PBR-like transparency and depth color adjustments
            color.a = clamp(lViewPosDifM * 0.1, 0.0, 0.95);
            
            #ifdef DISTANT_HORIZONS
                if (depthT == 1.0) color.a *= smoothstep(far, far * 0.9, lViewPos);
            #endif

            float waterFog = max0(1.0 - exp(-lViewPosDifM * 0.05));
            color.a = clamp(color.a + waterFog * 0.35, 0.15, 0.95);
            
            // Fade into the base color of the environment without darkening too much
            color.rgb = mix(color.rgb, baseColor, waterFog * 0.8);
            ////

            // No foam effects for vanilla look
            ////
        } else { // Underwater
            noDirectionalShading = true;

            reflectMult = 0.5;

            #if MC_VERSION < 11300 && WATER_STYLE >= 3
                color.a = 0.7;
            #endif

            #ifdef GBUFFERS_WATER
                #if WATER_STYLE == 1
                    translucentMult.rgb *= 1.0 - fresnel4;
                #else
                    translucentMult.rgb *= 1.0 - 0.9 * max(0.5 * sqrt(fresnel4), fresnel4);
                #endif
            #endif
        }
    #else
        shadowMult = vec3(0.0);
    #endif
    // ============================== End of Step 3 ============================== //

    // ============================== Step 4: Final Tweaks (Reflectify Edition) ============================== //
    reflectMult *= 1.35; 

    color.a = mix(color.a, 1.0, fresnel4);

    #ifdef GBUFFERS_WATER
        smoothnessG = 1.0; 
        highlightMult = 2.0; 
    #endif
    // ============================== End of Step 4 ============================== //
#endif
