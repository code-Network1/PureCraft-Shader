
vec3 GetRawWave(in vec3 pos, float wind) {
    float magnitude = sin(wind * 0.0027 + pos.z + pos.y) * 0.04 + 0.04;
    float d0 = sin(wind * 0.0127);
    float d1 = sin(wind * 0.0089);
    float d2 = sin(wind * 0.0114);
    vec3 wave;
    wave.x = sin(wind*0.0063 + d0 + d1 - pos.x + pos.z + pos.y) * magnitude;
    wave.z = sin(wind*0.0224 + d1 + d2 + pos.x - pos.z + pos.y) * magnitude;
    wave.y = sin(wind*0.0015 + d2 + d0 + pos.z + pos.y - pos.y) * magnitude;

    return wave;
}

vec3 GetWave(in vec3 pos, float waveSpeed) {
    float wind = frameTimeCounter * waveSpeed * WAVING_SPEED;
    vec3 wave = GetRawWave(pos, wind);

    #define WAVING_I_RAIN_MULT_M WAVING_I_RAIN_MULT * 0.01

    #if WAVING_I_RAIN_MULT > 100
        float windRain = frameTimeCounter * waveSpeed * WAVING_I_RAIN_MULT_M * WAVING_SPEED;
        vec3 waveRain = GetRawWave(pos, windRain);
        wave = mix(wave, waveRain, rainFactor);
    #endif

    #ifdef NO_WAVING_INDOORS
        wave *= clamp(lmCoord.y - 0.87, 0.0, 0.1);
    #else
        wave *= 0.1;
    #endif

    float wavingIntensity = WAVING_I * mix(1.0, WAVING_I_RAIN_MULT_M, rainFactor);

    return wave * wavingIntensity;
}

void DoWave_Foliage(inout vec3 playerPos, vec3 worldPos, float waveMult) {
    worldPos.y *= 0.5;

    vec3 wave = GetWave(worldPos, 170.0);
    wave.x = wave.x * 8.0 + wave.y * 4.0;
    wave.y = 0.0;
    wave.z = wave.z * 3.0;

    playerPos.xyz += wave * waveMult;
}

void DoWave_Leaves(inout vec3 playerPos, vec3 worldPos, float waveMult) {
    worldPos *= vec3(0.75, 0.375, 0.75);

    vec3 wave = GetWave(worldPos, 170.0);
    wave *= vec3(8.0, 3.0, 4.0);

    wave *= 1.0 - inSnowy; // Leaves with snow on top look wrong

    playerPos.xyz += wave * waveMult;
}

#ifndef TAU
#define TAU 6.28318530718
#endif

// ============================================================
// ReflectifyWave Wave System (Ported)
// ============================================================
#define GERSTNER_AMPLITUDE 0.25
#define GERSTNER_STEEPNESS 1.0
#define GERSTNER_SCALE 1.0
#define WATER_WAVE_SPEED 1.0
#define WATER_FOAM_STRENGTH 1.0
#define WATER_RIPPLES 1

void AddRippleHarmonic(vec2 wDir, float wLen, float wAmp, float wSteep, vec3 wPos, float wTime, inout vec3 disp, inout vec3 norm)
{
    float wvK = TAU / wLen;
    float wvC = sqrt(9.8 / wvK);
    float wvPhase = wvK * (dot(wDir, wPos.xz) - wvC * wTime);
    float wvQ = wSteep / (wvK * wAmp * 4.0);
    
    float cPhase = cos(wvPhase);
    float sPhase = sin(wvPhase);
    
    disp.x += wvQ * wAmp * wDir.x * cPhase;
    disp.z += wvQ * wAmp * wDir.y * cPhase;
    disp.y += wAmp * sPhase;
    
    norm.x -= wDir.x * wvK * wAmp * cPhase;
    norm.z -= wDir.y * wvK * wAmp * cPhase;
    norm.y -= wvQ * wvK * wAmp * sPhase;
}

void DoWave_Water(inout vec3 playerPos, vec3 worldPos) {
    vec3 disp = vec3(0.0);
    vec3 wNorm = vec3(0.0);
    
    float pRand = 1.0; // Static random since we don't have block coords easily here
    float simTime = frameTimeCounter;
    
    float ampBase = GERSTNER_AMPLITUDE;
    float steepBase = GERSTNER_STEEPNESS;
    float scaleBase = GERSTNER_SCALE;
    float speedBase = float(WATER_WAVE_SPEED) * 0.4;
    
    AddRippleHarmonic(normalize(vec2(1.0, 0.6)), 6.0 * scaleBase, ampBase * 1.0, steepBase, worldPos, simTime * speedBase, disp, wNorm);
    AddRippleHarmonic(normalize(vec2(-0.7, 1.0)), 4.5 * scaleBase, ampBase * 0.7, steepBase * 0.8, worldPos, simTime * speedBase * 0.9, disp, wNorm);
    AddRippleHarmonic(normalize(vec2(0.2, 1.0)), 2.5 * scaleBase, ampBase * 0.35, steepBase * 0.5, worldPos, simTime * speedBase * 1.4, disp, wNorm);
    AddRippleHarmonic(normalize(vec2(1.0, -0.3)), 1.8 * scaleBase, ampBase * 0.2, steepBase * 0.4, worldPos + vec3(pRand * 0.5, 0.0, pRand * 0.3), simTime * speedBase * 1.6, disp, wNorm);
    AddRippleHarmonic(normalize(vec2(-0.4, -0.9)), 1.2 * scaleBase, ampBase * 0.15, steepBase * 0.35, worldPos, simTime * speedBase * 2.2, disp, wNorm);

#if WATER_RIPPLES == 1
    float rtMod = simTime * float(WATER_WAVE_SPEED) * 1.2;
    wNorm.x += sin(worldPos.x * 3.7 + worldPos.z * 1.3 + rtMod) * 0.012;
    wNorm.z += cos(worldPos.x * 1.4 + worldPos.z * 3.1 + rtMod * 0.8) * 0.012;
#endif

    wNorm = normalize(vec3(wNorm.x, 1.0, wNorm.z));
    
    float camDist = length(playerPos.xz);
    float lodBlend = 1.0 - smoothstep(16.0, 64.0, camDist);
    
    disp *= lodBlend;
    wNorm = normalize(mix(vec3(0.0, 1.0, 0.0), wNorm, max(lodBlend, 0.05)));
    
    #ifdef NO_WAVING_INDOORS
        disp *= clamp(lmCoord.y - 0.87, 0.0, 0.1);
    #endif

    playerPos.xyz += disp;

    // Normal override for PureCraft Lite
    #if defined GBUFFERS_WATER && WATER_STYLE == 1
        normal = wNorm; // Apply the new generated normal directly to the vertex normal to influence lighting
    #endif
}

void DoWave_Lava(inout vec3 playerPos, vec3 worldPos) {
    if (fract(worldPos.y + 0.005) > 0.06) {
        float lavaWaveTime = frameTimeCounter * 3.0 * WAVING_SPEED;
        worldPos.xz *= 14.0;

        float wave  = sin(lavaWaveTime * 0.7 + worldPos.x * 0.14 + worldPos.z * 0.07);
              wave += sin(lavaWaveTime * 0.5 + worldPos.x * 0.05 + worldPos.z * 0.10);

        playerPos.y += wave * 0.0125;
    }
}

void DoWave(inout vec3 playerPos, int mat) {
    vec3 worldPos = playerPos.xyz + cameraPosition.xyz;

    #if defined GBUFFERS_TERRAIN || defined SHADOW
        #ifdef WAVING_FOLIAGE
            if (mat == 10005
                #ifdef DO_MORE_FOLIAGE_WAVING
                    || mat == 10769
                    || mat == 10924
                    || mat == 10972
                #endif
            ) { // Grounded Waving Foliage
                if (gl_MultiTexCoord0.t < mc_midTexCoord.t || fract(worldPos.y + 0.21) > 0.26)
                DoWave_Foliage(playerPos.xyz, worldPos, 1.0);
            }
            
            else if (mat == 10021) { // Upper Layer Waving Foliage
                DoWave_Foliage(playerPos.xyz, worldPos, 1.0);
            }

            #if defined WAVING_LEAVES || defined WAVING_LAVA || defined WAVING_LILY_PAD
                else
            #endif
        #endif

        #ifdef WAVING_LEAVES
            if (mat == 10009) { // Leaves
                DoWave_Leaves(playerPos.xyz, worldPos, 1.0);
            } else if (mat == 10013) { // Vine
                // Reduced waving on vines to prevent clipping through blocks
                DoWave_Leaves(playerPos.xyz, worldPos, 0.75);
            }
            #if defined NETHER || defined DO_NETHER_VINE_WAVING_OUTSIDE_NETHER
                else if (mat == 10884 || mat == 10885) { // Weeping Vines, Twisting Vines
                    float waveMult = 1.0;
                    DoWave_Foliage(playerPos.xyz, worldPos, waveMult);
                }
            #endif

            #if defined WAVING_LAVA || defined WAVING_LILY_PAD
                else
            #endif
        #endif

        #ifdef WAVING_LAVA
            if (mat == 10068) { // Lava
                DoWave_Lava(playerPos.xyz, worldPos);

                #ifdef GBUFFERS_TERRAIN
                    // G8FL735 Fixes Optifine-Iris parity. Optifine has 0.9 gl_Color.rgb on a lot of versions
                    glColorRaw.rgb = min(glColorRaw.rgb, vec3(0.9));
                #endif
            }

            #ifdef WAVING_LILY_PAD
                else
            #endif
        #endif

        #ifdef WAVING_LILY_PAD
            if (mat == 10489) { // Lily Pad
                DoWave_Water(playerPos.xyz, worldPos);
            }
        #endif
    #endif

    #if defined GBUFFERS_WATER || defined SHADOW
        #ifdef WAVING_WATER_VERTEX
            #if defined WAVING_ANYTHING_TERRAIN && defined SHADOW
                else
            #endif

            if (mat == 32000) { // Water
                if (fract(worldPos.y + 0.005) > 0.06)
                DoWave_Water(playerPos.xyz, worldPos);
            }
        #endif
    #endif
}
