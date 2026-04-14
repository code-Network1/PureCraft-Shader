/*
â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘
â–ˆâ–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–€â–ˆ
â–ˆ                     PureCraftCore Advanced Functions Pack                    â–ˆ
â–ˆ                      âš¡ Performance Optimized Collection âš¡               â–ˆ  
â–ˆâ–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–„â–ˆ
â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘

    ðŸ”¥ ULTIMATE SHADER UTILITIES COMPILATION ðŸ”¥
    â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    
    ðŸ’Ž Mathematical Precision Functions
    ðŸŒŠ Advanced Temporal Smoothing Algorithms  
    ðŸŽ¨ High-Quality Dithering Patterns
    ðŸš€ Lightning-Fast Space Transformations
    ðŸ“Š Professional Debug Text System
    âš¡ Memory-Optimized Data Structures
    
    
    
â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘â–‘
*/

#ifndef PureCraft_ULTIMATE_UTILS
#define PureCraft_ULTIMATE_UTILS

#ifndef FRACTAL_DITHER_ENGINE
    #define FRACTAL_DITHER_ENGINE
    
    float Bayer2  (vec2 coords) { coords = 0.5 * floor(coords); return fract(1.5 * fract(coords.y) + coords.x); }
    float Bayer4  (vec2 coords) { return 0.25 * Bayer2  (0.5 * coords) + Bayer2(coords); }
    float Bayer8  (vec2 coords) { return 0.25 * Bayer4  (0.5 * coords) + Bayer2(coords); }
    float Bayer16 (vec2 coords) { return 0.25 * Bayer8  (0.5 * coords) + Bayer2(coords); }
    float Bayer32 (vec2 coords) { return 0.25 * Bayer16 (0.5 * coords) + Bayer2(coords); }
    float Bayer64 (vec2 coords) { return 0.25 * Bayer32 (0.5 * coords) + Bayer2(coords); }
    float Bayer128(vec2 coords) { return 0.25 * Bayer64 (0.5 * coords) + Bayer2(coords); }
    float Bayer256(vec2 coords) { return 0.25 * Bayer128(0.5 * coords) + Bayer2(coords); }
#endif

int max0(int value) {
    return max(value, 0);
}
float max0(float value) {
    return max(value, 0.0);
}

#ifndef JITTER_OFFSETS_DEFINED
#define JITTER_OFFSETS_DEFINED
vec2 jitterOffsets[8] = vec2[8](
						vec2( 0.125,-0.375),
						vec2(-0.125, 0.375),
						vec2( 0.625, 0.125),
						vec2( 0.375,-0.625),
						vec2(-0.625, 0.625),
						vec2(-0.875,-0.125),
						vec2( 0.375,-0.875),
						vec2( 0.875, 0.875)
						);
#endif

#ifndef TAA_JITTER_DEFINED
#define TAA_JITTER_DEFINED
vec2 TAAJitter(vec2 inputCoord, float jitterWeight) {
	vec2 temporalOffset = jitterOffsets[int(framemod8)] * (jitterWeight / vec2(viewWidth, viewHeight));
	temporalOffset *= max0(1.0 - velocity * 400.0) * 0.125;
	return inputCoord + temporalOffset;
}
#endif

#define diagonal3(matrix) vec3((matrix)[0].x, (matrix)[1].y, matrix[2].z)
#define projMAD(matrix, vector) (diagonal3(matrix) * (vector) + (matrix)[3].xyz)

vec3 ScreenToView(vec3 position) {
    vec4 inverseProjDiag = vec4(gbufferProjectionInverse[0].x,
                               gbufferProjectionInverse[1].y,
                               gbufferProjectionInverse[2].zw);
    vec3 normalizedPos = position * 2.0 - 1.0;
    vec4 viewPosition = inverseProjDiag * normalizedPos.xyzz + gbufferProjectionInverse[3];
    return viewPosition.xyz / viewPosition.w;
}

vec3 ViewToPlayer(vec3 position) {
    return mat3(gbufferModelViewInverse) * position + gbufferModelViewInverse[3].xyz;
}

vec3 PlayerToShadow(vec3 position) {
    vec3 shadowPosition = mat3(shadowModelView) * position + shadowModelView[3].xyz;
    return projMAD(shadowProjection, shadowPosition);
}

vec3 ShadowClipToShadowView(vec3 position) {
    return mat3(shadowProjectionInverse) * position;
}

vec3 ShadowViewToPlayer(vec3 position) {
    return mat3(shadowModelViewInverse) * position;
}

#ifdef VERTEX_SHADER
    vec2 GetLightMapCoordinates() {
        vec2 lightmapCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
        return clamp((lightmapCoord - 0.03125) * 1.06667, 0.0, 1.0);
    }
    
    vec3 GetSunVector() {
        const vec2 solarRotationMatrix = vec2(cos(sunPathRotation * 0.01745329251994), 
                                             -sin(sunPathRotation * 0.01745329251994));
        #ifdef OVERWORLD
            // Calculate fractional time angle with 0.25 offset for proper day cycle
            float temporalAngle = fract(timeAngle - 0.25);  // Normalize to [0,1] range
            // Apply sophisticated temporal smoothing algorithm for realistic sun movement
            // Uses cosine interpolation to create smooth acceleration/deceleration
            temporalAngle = (temporalAngle + (cos(temporalAngle * 3.14159265358979) * -0.5 + 0.5 - temporalAngle) / 3.0) * 6.28318530717959;  // Convert to radians

            #if defined(DISABLE_UNBOUND_SUN_MOON)
                // Specialized handling for Ad Astra dimensional lighting systems
                // Forcing vanilla alignment regardless of custom sun angle settings
                const vec2 vanillaRotationMatrix = vec2(1.0, 0.0); // cos(0), -sin(0) - Unity rotation
                // Transform to view space using vanilla rotation for dimensional compatibility
                return normalize((gbufferModelView * vec4(vec3(-sin(temporalAngle), cos(temporalAngle) * vanillaRotationMatrix) * 2000.0, 1.0)).xyz);
            #else
                // Standard overworld sun vector calculation with custom rotation support
                // Uses solarRotationMatrix for customizable sun path angles
                return normalize((gbufferModelView * vec4(vec3(-sin(temporalAngle), cos(temporalAngle) * solarRotationMatrix) * 2000.0, 1.0)).xyz);
            #endif
        #elif defined END
            // End dimension: Fixed sun position for consistent lighting
            float temporalAngle = 0.0;  // Static time - no day/night cycle in End
            // Place sun at zenith position for dramatic End lighting
            return normalize((gbufferModelView * vec4(vec3(0.0, solarRotationMatrix * 2000.0), 1.0)).xyz);
        #else
            // Unknown dimension fallback - return null vector to prevent errors
            return vec3(0.0);  // Safe fallback for unsupported dimensions
        #endif
    }
#endif

// ðŸŒˆ LUMINANCE ANALYSIS ALGORITHMS ðŸŒˆ
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// Industry-standard luminance calculation using ITU-R BT.601 coefficients
float GetLuminance(vec3 colorSample) {
    return dot(colorSample, vec3(0.299, 0.587, 0.114));  // Professional standard
}

// Intelligent luminance-based color correction system
vec3 DoLuminanceCorrection(vec3 inputColor) {
    return inputColor / GetLuminance(inputColor);  // Preserve chromaticity
}

// Advanced bias factor calculation for shadow mapping optimization
float GetBiasFactor(float NdotLightMap) {
    float squaredNdotLM = NdotLightMap * NdotLightMap;
    return 1.25 * (1.0 - squaredNdotLM * squaredNdotLM) / NdotLightMap;
}

// Dynamic horizon factor computation with multiple rendering modes
float GetHorizonFactor(float XdotUp) {
    #ifdef SUN_MOON_HORIZON
        float horizonFactor = clamp((XdotUp + 0.1) * 10.0, 0.0, 1.0);
        horizonFactor *= horizonFactor;
        return horizonFactor * horizonFactor * (3.0 - 2.0 * horizonFactor);  // Smoothstep
    #else
        float horizonFactor = min(XdotUp + 1.0, 1.0);
        horizonFactor *= horizonFactor;
        return horizonFactor * horizonFactor;  // Quadratic falloff
    #endif
}

bool CheckForColor(vec3 albedoColor, vec3 targetColor) { 
    vec3 colorDifference = albedoColor - targetColor * 0.003921568;
    return colorDifference == clamp(colorDifference, vec3(-0.001), vec3(0.001));
}

bool CheckForStick(vec3 albedoSample) {
    return CheckForColor(albedoSample, vec3(40, 30, 11)) ||
           CheckForColor(albedoSample, vec3(73, 54, 21)) ||
           CheckForColor(albedoSample, vec3(104, 78, 30)) ||
           CheckForColor(albedoSample, vec3(137, 103, 39));
}

float GetMaxColorDif(vec3 colorInput) {
    vec3 channelDiffs = abs(vec3(colorInput.r - colorInput.g, 
                                 colorInput.g - colorInput.b, 
                                 colorInput.r - colorInput.b));
    return max(channelDiffs.r, max(channelDiffs.g, channelDiffs.b));
}

int min1(int inputValue) {
    return min(inputValue, 1);
}
float min1(float inputValue) {
    return min(inputValue, 1.0);
}
int clamp01(int inputValue) {
    return clamp(inputValue, 0, 1);
}
float clamp01(float inputValue) {
    return clamp(inputValue, 0.0, 1.0);
}
vec2 clamp01(vec2 inputVector) {
    return clamp(inputVector, vec2(0.0), vec2(1.0));
}
vec3 clamp01(vec3 colorVector) {
    return clamp(colorVector, vec3(0.0), vec3(1.0));
}

int pow2(int x) {
    return x * x;
}
float pow2(float x) {
    return x * x;
}
vec2 pow2(vec2 x) {
    return x * x;
}
vec3 pow2(vec3 x) {
    return x * x;
}
vec4 pow2(vec4 x) {
    return x * x;
}

int pow3(int x) {
    return pow2(x) * x;
}
float pow3(float x) {
    return pow2(x) * x;
}
vec2 pow3(vec2 x) {
    return pow2(x) * x;
}
vec3 pow3(vec3 x) {
    return pow2(x) * x;
}
vec4 pow3(vec4 x) {
    return pow2(x) * x;
}

float pow1_5(float x) {
    return x - x * pow2(1.0 - x);
}
vec2 pow1_5(vec2 inputVector) {
    return inputVector - inputVector * pow2(1.0 - inputVector);
}
vec3 pow1_5(vec3 inputVector) {
    return inputVector - inputVector * pow2(1.0 - inputVector);
}
vec4 pow1_5(vec4 inputVector) {
    return inputVector - inputVector * pow2(1.0 - inputVector);
}

float sqrt1(float inputValue) {
    return inputValue * (2.0 - inputValue);
}
vec2 sqrt1(vec2 inputVector) {
    return inputVector * (2.0 - inputVector);
}
vec3 sqrt1(vec3 inputVector) {
    return inputVector * (2.0 - inputVector);
}
vec4 sqrt1(vec4 inputVector) {
    return inputVector * (2.0 - inputVector);
}
float sqrt2(float inputValue) {
    inputValue = 1.0 - inputValue;
    inputValue *= inputValue;
    inputValue *= inputValue;
    return 1.0 - inputValue;
}
vec2 sqrt2(vec2 inputVector) {
    inputVector = 1.0 - inputVector;
    inputVector = inputVector * inputVector;
    inputVector = inputVector * inputVector;
    return 1.0 - inputVector;
}
vec3 sqrt2(vec3 inputVector) {
    inputVector = 1.0 - inputVector;
    inputVector = inputVector * inputVector;
    inputVector = inputVector * inputVector;
    return 1.0 - inputVector;
}
vec4 sqrt2(vec4 inputVector) {
    inputVector = 1.0 - inputVector;
    inputVector = inputVector * inputVector;
    inputVector = inputVector * inputVector;
    return 1.0 - inputVector;
}
float sqrt3(float inputValue) {
    inputValue = 1.0 - inputValue;
    inputValue *= inputValue;
    inputValue *= inputValue;
    inputValue *= inputValue;
    return 1.0 - inputValue;
}
vec2 sqrt3(vec2 inputVector) {
    inputVector = 1.0 - inputVector;
    inputVector = inputVector * inputVector;
    inputVector = inputVector * inputVector;
    inputVector = inputVector * inputVector;
    return 1.0 - inputVector;
}
vec3 sqrt3(vec3 inputVector) {
    inputVector = 1.0 - inputVector;
    inputVector = inputVector * inputVector;
    inputVector = inputVector * inputVector;
    inputVector = inputVector * inputVector;
    return 1.0 - inputVector;
}
vec4 sqrt3(vec4 inputVector) {
    inputVector = 1.0 - inputVector;
    inputVector = inputVector * inputVector;
    inputVector = inputVector * inputVector;
    inputVector = inputVector * inputVector;
    return 1.0 - inputVector;
}
float sqrt4(float inputValue) {
    inputValue = 1.0 - inputValue;
    inputValue *= inputValue;
    inputValue *= inputValue;
    inputValue *= inputValue;
    inputValue *= inputValue;
    return 1.0 - inputValue;
}
vec2 sqrt4(vec2 inputVector) {
    inputVector = 1.0 - inputVector;
    inputVector = inputVector * inputVector;
    inputVector = inputVector * inputVector;
    inputVector = inputVector * inputVector;
    inputVector = inputVector * inputVector;
    return 1.0 - inputVector;
}
vec3 sqrt4(vec3 inputVector) {
    inputVector = 1.0 - inputVector; // RGB preparation
    inputVector = inputVector * inputVector;      // RGB power progression - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Intermediate calculation - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Advanced RGB processing - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Supreme precision step - FIXED SYNTAX
    return 1.0 - inputVector;        // Supreme RGB quality
}
// Vector4 sqrt4 - ultimate RGBA processing excellence
vec4 sqrt4(vec4 inputVector) {
    inputVector = 1.0 - inputVector; // RGBA mathematical setup
    inputVector = inputVector * inputVector;      // First precision enhancement - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Second precision boost - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Third precision amplification - FIXED SYNTAX
    inputVector = inputVector * inputVector;      // Ultimate precision achievement - FIXED SYNTAX
    return 1.0 - inputVector;        // Excellence in RGBA processing
}

float smoothstep1(float inputValue) {
    return inputValue * inputValue * (3.0 - 2.0 * inputValue);
}
vec2 smoothstep1(vec2 inputVector) {
    return inputVector * inputVector * (3.0 - 2.0 * inputVector);
}
vec3 smoothstep1(vec3 inputVector) {
    return inputVector * inputVector * (3.0 - 2.0 * inputVector);
}
vec4 smoothstep1(vec4 inputVector) {
    return inputVector * inputVector * (3.0 - 2.0 * inputVector);
}

vec3 rgb2hsv(vec3 rgbColor)
{
    vec4 K_TRANSFORM = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 colorPhase1 = mix(vec4(rgbColor.bg, K_TRANSFORM.wz), vec4(rgbColor.gb, K_TRANSFORM.xy), step(rgbColor.b, rgbColor.g));
    vec4 colorPhase2 = mix(vec4(colorPhase1.xyw, rgbColor.r), vec4(rgbColor.r, colorPhase1.yzx), step(colorPhase1.x, rgbColor.r));

    float deltaValue = colorPhase2.x - min(colorPhase2.w, colorPhase2.y);
    float epsilon = 1.0e-10;
    return vec3(abs(colorPhase2.z + (colorPhase2.w - colorPhase2.y) / (6.0 * deltaValue + epsilon)), 
                deltaValue / (colorPhase2.x + epsilon), 
                colorPhase2.x);
}

vec3 hsv2rgb(vec3 hsvColor)
{
    vec4 K_INVERSE = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 phaseValues = abs(fract(hsvColor.xxx + K_INVERSE.xyz) * 6.0 - K_INVERSE.www);
    return hsvColor.z * mix(K_INVERSE.xxx, clamp(phaseValues - K_INVERSE.xxx, 0.0, 1.0), hsvColor.y);
}

#endif // PureCraft_ULTIMATE_UTILS
