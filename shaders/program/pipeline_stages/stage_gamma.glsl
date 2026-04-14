/*============================================
 * PureCraft Shader - Pipeline Stage Gamma
 * DSLR Cinematic DoF â€” MipMap Edition v4
 * Smooth, Artifact-Free, Gradient Blur
 * by in2bubble / EminGT
 *============================================*/

#include "/lib/shader_modules/shader_master.glsl"

#ifdef FRAGMENT_SHADER

#if WORLD_BLUR > 0 || defined DSLR_AUTOFOCUS_DOF
    noperspective in vec2 texCoord;
    flat in vec3 upVec, sunVec;
#endif

// MipMaps are REQUIRED for the smooth blur technique
#if WORLD_BLUR > 0 || defined DSLR_AUTOFOCUS_DOF
    const bool colortex0MipmapEnabled = true;
#endif

// centerDepthSmooth: Iris/Optifine tracks screen-centre depth with temporal smoothing
// â†’ provides natural focus animation when aiming at different objects
#ifdef DSLR_AUTOFOCUS_DOF
    uniform float centerDepthSmooth;
#endif

#if WORLD_BLUR > 0
    #if WORLD_BLUR == 2 && WB_DOF_FOCUS >= 0
        #if WB_DOF_FOCUS == 0
            #ifndef DSLR_AUTOFOCUS_DOF
                uniform float centerDepthSmooth;
            #endif
        #else
            float centerDepthSmooth = (far * (WB_DOF_FOCUS - near)) / (WB_DOF_FOCUS * (far - near));
        #endif
    #endif
#endif

#if WORLD_BLUR > 0 || defined DSLR_AUTOFOCUS_DOF
    float SdotU    = dot(sunVec, upVec);
    float sunFactor = SdotU < 0.0
        ? clamp(SdotU + 0.375,  0.0, 0.75)  / 0.75
        : clamp(SdotU + 0.03125,0.0, 0.0625)/ 0.0625;

    vec2 dofOffsets[18] = vec2[18](
        vec2( 0.0    , 0.25   ), vec2(-0.2165,  0.125 ), vec2(-0.2165, -0.125),
        vec2( 0      ,-0.25   ), vec2( 0.2165, -0.125 ), vec2( 0.2165,  0.125),
        vec2( 0      , 0.5    ), vec2(-0.25  ,  0.433 ), vec2(-0.433 ,  0.25 ),
        vec2(-0.5    , 0      ), vec2(-0.433 , -0.25  ), vec2(-0.25  , -0.433),
        vec2( 0      ,-0.5    ), vec2( 0.25  , -0.433 ), vec2( 0.433 , -0.2  ),
        vec2( 0.5    , 0      ), vec2( 0.433 ,  0.25  ), vec2( 0.25  ,  0.433)
    );
#endif

// â”€â”€â”€ Original World Blur (unchanged) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
#if WORLD_BLUR > 0
    void DoWorldBlur(inout vec3 color, float z1, float lViewPos0) {
        if (z1 < 0.56) return;
        vec3 dof = vec3(0.0); vec2 dofScale = vec2(1.0, aspectRatio);
        #if WORLD_BLUR == 1
            #ifdef OVERWORLD
                float dbMult;
                if (isEyeInWater == 0) {
                    dbMult = mix(WB_DB_NIGHT_I, WB_DB_DAY_I, sunFactor * eyeBrightnessM);
                    dbMult = mix(dbMult, WB_DB_RAIN_I, rainFactor * eyeBrightnessM);
                } else dbMult = WB_DB_WATER_I;
            #elif defined NETHER
                float dbMult = WB_DB_NETHER_I;
            #elif defined END
                float dbMult = WB_DB_END_I;
            #endif
            float coc = clamp(lViewPos0 * 0.001, 0.0, 0.1) * dbMult * 0.03;
        #elif WORLD_BLUR == 2
            #if WB_DOF_FOCUS >= 0
                float coc = max(abs(z1 - centerDepthSmooth) * 0.125 * WB_DOF_I - 0.0001, 0.0);
            #elif WB_DOF_FOCUS == -1
                float coc = clamp(abs(lViewPos0 * 0.005 - pow2(vsBrightness)), 0.0, 0.1) * WB_DOF_I * 0.03;
            #endif
        #endif
        coc = coc / sqrt(coc * coc + 0.1);
        #ifdef WB_FOV_SCALED
            coc *= gbufferProjection[1][1] * 0.8;
        #endif
        if (coc * 0.5 > 1.0 / max(viewWidth, viewHeight)) {
            for (int i = 0; i < 18; i++) {
                vec2 offset = dofOffsets[i] * coc * 0.0085 * dofScale;
                float lod   = log2(viewHeight * aspectRatio * coc * 0.75 / 320.0);
                dof += texture2DLod(colortex0, texCoord + offset, lod).rgb;
            }
            dof /= 18.0; color = dof;
        }
    }
#endif

/*â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
 *  DSLR Cinematic Auto-Focus DoF â€” MipMap Edition v4
 *
 *
 *  â”€â”€â”€â”€â”€â”€â”€â”€â”€
 *â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•*/
#ifdef DSLR_AUTOFOCUS_DOF

// Linearise nonlinear depth [0,1] â†’ world-space metres
float DSLR_Lin(float d) {
    return 2.0 * near * far / (far + near - d * (far - near));
}

// Rotation matrix for jitter
mat2 DSLR_Rot(float a) {
    float s = sin(a), c = cos(a);
    return mat2(c, -s, s, c);
}

/*â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
 *  DoDSLRDoF (v4 â€” MipMap-driven, gradient, no artifacts)
 *
 *  CoC formula (thin-lens approximation):
 *    coc = aperture Ã— (1 âˆ’ focusDist / pixelDist)
 *  â†’ 0 when pixelDist == focusDist (perfectly in focus)
 *  â†’ APERTURE when pixelDist â†’ âˆž (sky, maximum blur)
 *  â†’ Natural gradient between near objects and sky âœ“
 *
 *  Activation formula:
 *    activationFactor = 1 âˆ’ smoothstep(nearEdge, farEdge, focusDist)
 *  â†’ 1.0 when looking at close objects
 *  â†’ Gradually fades to 0 as you look farther away
 *  â†’ No hard cutoff, no sudden pop-in
 *â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€*/
void DoDSLRDoF(inout vec3 color, float z0, float z1) {

    //â•â• â‘  Guard: crosshair hitting sky â†’ no DoF â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    if (centerDepthSmooth > 0.9998) return;

    float focusDist = DSLR_Lin(centerDepthSmooth);

    //â•â• â‘¡ Smooth global activation â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    // Fades from 1.0 (close focus) to 0.0 (far focus) with no hard cut.
    // nearEdge: DoF fully active below this (blocks)
    // farEdge: DoF fully inactive above this (blocks) = DSLR_NEAR_BLUR_START
    float nearEdge        = DSLR_NEAR_BLUR_START * 0.2;
    float farEdge         = DSLR_NEAR_BLUR_START;
    float activationFactor = 1.0 - smoothstep(nearEdge, farEdge, focusDist);

    // Already inactive â†’ skip all computation
    if (activationFactor < 0.005) return;

    //â•â• â‘¢ Protect hand and held items â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    if (z0 < 0.56) return;

    //â•â• â‘£ Pixel distance â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    // Sky (z0 â‰¥ 1): treated as at far-plane Ã— 8 so it always blurs fully
    float pixelDist;
    if (z0 >= 0.9999) {
        pixelDist = far * 8.0;
    } else {
        // Use the closer of opaque / translucent depth layers
        float zUse = (z1 < 0.9999 && z1 < z0) ? z1 : z0;
        pixelDist  = DSLR_Lin(zUse);
    }

    //â•â• â‘¤ Only blur objects BEHIND the focal plane â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    float distFromFocus = pixelDist - focusDist;
    if (distFromFocus < 0.25) return;  // in-focus or in front â†’ sharp

    //â•â• â‘¥ Circle of Confusion (thin-lens) â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    // Natural gradient: grows from 0 at focus to APERTURE at infinity
    float coc = DSLR_APERTURE * (1.0 - focusDist / max(pixelDist, 0.001));

    // Apply global activation and user strength
    coc *= DSLR_BOKEH_STRENGTH * activationFactor;
    coc  = clamp(coc, 0.0, 1.0);

    // Pixel is effectively sharp â†’ skip
    if (coc < 0.5 / min(viewWidth, viewHeight)) return;

    //â•â• â‘¦ MipMap-driven soft blur â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    // This is the key technique:
    // LOD controls how many pixels are averaged by the GPU hardware.
    // High LOD = naturally smooth, Gaussian-like blur with ZERO edge artifacts.
    // It's the closest thing to a real lens you can achieve in screen space.
    //
    // LOD mapping:
    //   coc = 0.00 â†’ LOD = 0.0  (original sharpness)
    //   coc = 0.25 â†’ LOD = 1.25 (slight softness)
    //   coc = 0.50 â†’ LOD = 2.50 (medium blur)
    //   coc = 0.75 â†’ LOD = 3.75 (strong blur)
    //   coc = 1.00 â†’ LOD = 5.00 (full blur â€” sky, far background)
    //
    float primaryLod = coc * 5.0;

    //â”€â”€ Stage A: pure mipmap sample (handles edges, no artifacts) â”€â”€
    vec3 mipColor = texture2DLod(colortex0, texCoord, primaryLod).rgb;

    //â”€â”€ Stage B: a handful of offset samples for bokeh shape hint â”€â”€
    // We use a smaller number here since mipmaps do 90% of the work.
    // Each offset sample reads at an ELEVATED LOD so that even the
    // sample positions don't introduce sharp foreground specks.
    float jitter    = fract(sin(dot(texCoord, vec2(127.1, 311.7))) * 43758.5453
                         + float(frameCounter) * 0.6180339);
    mat2  rot       = DSLR_Rot(jitter * 6.28318530718);
    float fovScale  = max(gbufferProjection[0][0], 0.5);
    float blurUV    = coc * 0.020 / fovScale;
    vec2  aFix      = vec2(1.0, viewWidth / viewHeight);

    vec3  bokeh = mipColor;
    float wSum  = 1.0;

    // Use at most 12 offset samples (DSLR_BOKEH_SAMPLES / 2 capped at 12)
    // to keep the GPU cost low while adding the round bokeh shape.
    int N    = min(DSLR_BOKEH_SAMPLES / 2, 12);
    float iN = 1.0 / float(N);

    for (int i = 0; i < N; i++) {
        float t      = (float(i) + 0.5) * iN;
        float angle  = t * 6.28318530718 * 2.3999632; // golden angle spiral
        float radius = sqrt(t);                         // disc area compensation

        #if DSLR_BOKEH_SHAPE == 1
            // Hexagonal (cinema anamorphic lens)
            vec2 hd = vec2(cos(angle), sin(angle));
            radius *= 0.5 / max(abs(hd.x), abs(hd.y) * 0.57735);
        #endif

        vec2 dir    = rot * vec2(cos(angle), sin(angle));
        vec2 offset = dir * radius * blurUV * aFix;

        // Elevated LOD for samples to prevent sharp foreground from
        // bleeding into the blurred background (key to clean edges)
        float sLod = primaryLod + radius * 1.5;
        vec3  s    = texture2DLod(colortex0, texCoord + offset, sLod).rgb;

        // Gaussian-like weight: centre disc counts more â†’ softer bokeh shape
        float w = exp(-radius * radius * 2.0);
        bokeh  += s * w;
        wSum   += w;
    }
    bokeh /= wSum;

    //â”€â”€ Combine: mipmap base (soft) + bokeh hint (shape) â”€â”€â”€â”€â”€â”€â”€â”€
    // 65% mip (smooth/no-artifacts) + 35% bokeh (shape)
    vec3 finalBlur = mix(mipColor, bokeh, 0.35);

    //â•â• â‘§ Smooth blend â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    // Double smoothstep for an extra-silky transition from sharp to blurry.
    // This eliminates any remaining hard edges in the blend.
    float t      = smoothstep(0.0, 0.15, coc);
    float blend  = t * t * (3.0 - 2.0 * t);  // smoothstepÂ²
    color = mix(color, finalBlur, blend);
}

#endif // DSLR_AUTOFOCUS_DOF

// â”€â”€ Main â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
void main() {
    vec3 color = texelFetch(colortex0, texelCoord, 0).rgb;

    #if WORLD_BLUR > 0 || defined DSLR_AUTOFOCUS_DOF
        float z1 = texelFetch(depthtex1, texelCoord, 0).r;
        float z0 = texelFetch(depthtex0, texelCoord, 0).r;

        vec4 screenPos = vec4(texCoord, z0, 1.0);
        vec4 viewPos   = gbufferProjectionInverse * (screenPos * 2.0 - 1.0);
        viewPos       /= viewPos.w;
        float lViewPos = length(viewPos.xyz);

        #if defined DISTANT_HORIZONS && defined NETHER
            float z0DH = texelFetch(dhDepthTex, texelCoord, 0).r;
            vec4 screenPosDH = vec4(texCoord, z0DH, 1.0);
            vec4 viewPosDH   = dhProjectionInverse * (screenPosDH * 2.0 - 1.0);
            viewPosDH       /= viewPosDH.w;
            lViewPos         = min(lViewPos, length(viewPosDH.xyz));
        #endif

        #if WORLD_BLUR > 0
            DoWorldBlur(color, z1, lViewPos);
        #endif

        #ifdef DSLR_AUTOFOCUS_DOF
            DoDSLRDoF(color, z0, z1);
        #endif

    #endif

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, 1.0);
}
#endif // FRAGMENT_SHADER

/*============================================
 * VERTEX SHADER
 *============================================*/
#ifdef VERTEX_SHADER

#if WORLD_BLUR > 0 || defined DSLR_AUTOFOCUS_DOF
    noperspective out vec2 texCoord;
    flat out vec3 upVec, sunVec;
#endif

void main() {
    gl_Position = ftransform();
    #if WORLD_BLUR > 0 || defined DSLR_AUTOFOCUS_DOF
        texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
        upVec    = normalize(gbufferModelView[1].xyz);
        sunVec   = GetSunVector();
    #endif
}

#endif
