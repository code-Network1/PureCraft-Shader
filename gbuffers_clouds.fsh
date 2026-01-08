#version 120
#include "lib/shader_config.glsl"

// Force enable clouds
#define ENABLE_VOLUMETRIC_CLOUDS
#define CLOUD_QUALITY 3

//Varyings//    // Enhanced color mixing
    vec3 cloudColor = mix(nightCloudColor, dayCloudColor, dayFactor);
    cloudColor = mix(cloudColor, sunsetCloudColor, sunsetFactor * 0.9);
    cloudColor = mix(cloudColor, morningCloudColor, morningFactor * 0.7);
    
    // Enhanced rain clouds effect
    cloudColor = mix(cloudColor, cloudColor * 0.3, rainStrength);
    cloudDensity = mix(cloudDensity, cloudDensity * 1.4, rainStrength);
    
    // Enhanced 3D cloud shading with multiple light sources
    vec3 lightDir = normalize(sunPosition);
    float heightFactor = max(0.3, dot(normal, lightDir));
    float edgeFactor = 1.0 - pow(cloudDensity, 2.0);
    heightFactor = mix(heightFactor, heightFactor * 1.5, edgeFactor);
    
    cloudColor *= heightFactor * 1.2;
    
    return vec4(cloudColor, cloudDensity * cloudTexture.a * 1.1);c4 color;
varying vec2 coord0;
varying vec2 coord1;
varying vec3 worldPos;
varying vec3 normal;

//Uniforms//
uniform sampler2D texture;
uniform sampler2D lightmap;
uniform int worldTime;
uniform float frameTimeCounter;
uniform float rainStrength;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform int fogMode;

const int GL_LINEAR = 9729;
const int GL_EXP = 2048;

// Advanced cloud rendering
vec4 getCloudColor(vec2 texCoord, vec3 worldPos, float timeOfDay) {
    vec4 cloudTexture = texture2D(texture, texCoord);
    
    // Enhanced cloud movement animation with multiple speeds
    vec2 wind1 = vec2(frameTimeCounter * 0.012, frameTimeCounter * 0.005);
    vec2 wind2 = vec2(frameTimeCounter * 0.018, frameTimeCounter * 0.008);
    vec2 wind3 = vec2(frameTimeCounter * 0.006, frameTimeCounter * 0.015);
    
    // Multiple cloud layers for enhanced 3D depth
    float cloud1 = texture2D(texture, texCoord + wind1).a;
    float cloud2 = texture2D(texture, texCoord * 0.6 + wind2).a;
    float cloud3 = texture2D(texture, texCoord * 1.5 - wind1 * 0.7).a;
    float cloud4 = texture2D(texture, texCoord * 2.1 + wind3 * 0.3).a;
    float cloud5 = texture2D(texture, texCoord * 0.4 - wind2 * 0.5).a;
    
    // Enhanced layer combination for 3D effect
    float cloudDensity = (cloud1 * 1.0 + cloud2 * 0.8 + cloud3 * 0.6 + cloud4 * 0.4 + cloud5 * 0.9) / 3.7;
    cloudDensity = pow(cloudDensity, 1.2);
    
    // Enhanced cloud colors with better lighting
    vec3 dayCloudColor = vec3(1.0, 1.0, 1.0);
    vec3 nightCloudColor = vec3(0.25, 0.28, 0.35);
    vec3 sunsetCloudColor = vec3(1.1, 0.9, 0.8);
    vec3 morningCloudColor = vec3(1.0, 0.98, 0.95);
    
    // Enhanced time factors
    float dayFactor = max(0.0, cos(timeOfDay * 3.14159));
    float sunsetFactor = max(0.0, 1.0 - abs(timeOfDay - 0.5) * 3.5);
    float morningFactor = max(0.0, 1.0 - abs(timeOfDay - 0.2) * 4.0);
    
    // Enhanced color mixing
    vec3 cloudColor = mix(nightCloudColor, dayCloudColor, dayFactor);
    cloudColor = mix(cloudColor, sunsetCloudColor, sunsetFactor * 0.8);
    
    // Rain clouds are darker
    cloudColor = mix(cloudColor, cloudColor * 0.4, rainStrength);
    
    // Cloud shading based on height
    float heightFactor = max(0.2, dot(normal, normalize(sunPosition)));
    cloudColor *= heightFactor;
    
    return vec4(cloudColor, cloudDensity * cloudTexture.a);
}

void main() {
    // Enhanced time calculation
    float timeOfDay = float(worldTime) / 24000.0;
    
    // Get enhanced cloud color
    vec4 cloudColor = getCloudColor(coord0, worldPos, timeOfDay);
    vec3 lightColor = texture2D(lightmap, coord1).rgb;
    
    // Enhanced lighting calculation
    vec4 albedo = cloudColor * color;
    albedo.rgb *= lightColor * 1.3;
    
    // Enhanced volumetric rain effect
    if (rainStrength > 0.1) {
        // Enhanced cloud density and darkness during rain
        albedo.a = min(1.0, albedo.a * (1.0 + rainStrength * 0.7));
        albedo.rgb *= 1.0 - rainStrength * 0.2;
        
        // Enhanced rain particle effect with 3D noise
        vec2 rainCoord = coord0 * 25.0;
        rainCoord.y += frameTimeCounter * 12.0;
        rainCoord.x += sin(frameTimeCounter * 3.0) * 2.0;
        
        float rainPattern1 = fract(sin(dot(rainCoord, vec2(12.9898, 78.233))) * 43758.5453);
        float rainPattern2 = fract(sin(dot(rainCoord * 1.3, vec2(15.1234, 92.567))) * 37281.1923);
        
        float rainEffect = (rainPattern1 + rainPattern2) * 0.5;
        
        if (rainEffect > 0.97) {
            albedo.rgb += vec3(0.7, 0.8, 0.9) * 0.4 * rainStrength;
        }
        
        // Add lightning flash effect occasionally
        float lightningChance = fract(sin(frameTimeCounter * 0.1) * 1234.5678);
        if (lightningChance > 0.998 && rainStrength > 0.5) {
            albedo.rgb += vec3(0.9, 0.95, 1.0) * 2.0;
        }
    }
    
    // Fog calculation
    if(fogMode == GL_LINEAR) {
        float fog = clamp((gl_FogFragCoord - gl_Fog.start) * gl_Fog.scale * 0.3, 0., 1.);
        albedo.rgb = mix(albedo.rgb, gl_Fog.color.rgb, fog);
    }
    
    /*DRAWBUFFERS:0*/
    gl_FragData[0] = albedo;
}
