// PureCraft Shader - Vanilla-Purity Flower System
// Calm & enchanting style - NO yellow/orange glow, subtle soft colors only

#ifdef GBUFFERS_TERRAIN
    DoFoliageColorTweaks(color.rgb, shadowMult, snowMinNdotU, viewPos, nViewPos, lViewPos, dither);

#endif

// Double-check: STRICT grass exclusion to prevent ANY grass glow
bool hasStrongGreenDominance = (color.g > 0.3 && color.g > color.r * 1.1 && color.g > color.b * 1.1) ||
                               (color.g > 0.4 && (color.r + color.b) < 0.6); // Extra grass protection
if (hasStrongGreenDominance) {
    // This looks like grass, skip ALL flower effects
    materialMask = 0.0;
    emission = 0.0; // Force no emission for grass-like materials
} else {
    // REDUCED flower lighting system - subtle glow only
    float brightness = dot(color.rgb, vec3(0.299, 0.587, 0.114));

    // Calm vanilla-purity flower color detection - subtle soft enchanting glow only
    if (color.r > color.g + 0.15 && color.r > color.b + 0.15 && color.r > 0.5 && brightness > 0.4) {
        // Red flowers (Rose, Poppy, Red Tulip) - very soft warm glow
        emission = 0.35 + brightness * 0.2; // Gentle, warm vanilla feel
        color.rgb *= vec3(1.02, 0.99, 0.98); // Almost no tint change
    } else if (color.b > color.r + 0.15 && color.b > color.g + 0.15 && color.b > 0.5 && brightness > 0.4) {
        // Blue flowers (Cornflower, Blue Orchid) - enchanting soft sky glow
        emission = 0.4 + brightness * 0.25; // Gentle blue enchantment
        color.rgb *= vec3(0.98, 0.99, 1.02); // Barely visible cool tint
    } else if (color.r > 0.7 && color.g > 0.7 && color.b < 0.3 && brightness > 0.5) {
        // Yellow flowers (Dandelion, Sunflower) - no emission
        emission = 0.0;
    } else if (color.r > 0.5 && color.g < 0.35 && color.b > 0.5 && brightness > 0.4) {
        // Purple/Magenta flowers (Allium, Purple Tulip) - calm soft glow
        emission = 0.35 + brightness * 0.25; // Very gentle, enchanting
        color.rgb *= vec3(1.02, 0.97, 1.03); // Minimal tint
    } else if (color.r > 0.6 && color.g > 0.45 && color.b < 0.35 && brightness > 0.4) {
        // Orange flowers - no emission
        emission = 0.0;
    } else if (color.r > 0.7 && color.g > 0.7 && color.b > 0.7 && brightness > 0.5) {
        // White flowers (White Tulip, Oxeye Daisy) - soft pure moonlit glow
        emission = 0.3 + brightness * 0.15; // Gentle purity, like vanilla snow
        color.rgb *= vec3(1.005, 1.005, 1.01); // Near-invisible tint
    } else if (color.r > 0.6 && color.g > 0.4 && color.b > 0.6 && brightness > 0.4) {
        // Pink flowers (Pink Tulip) - enchanting whisper-soft pink glow
        emission = 0.3 + brightness * 0.15; // Whisper-soft glow
        color.rgb *= vec3(1.01, 0.99, 1.005); // Very gentle aesthetic
    } else {
        // No clear flower pattern detected - NO emission
        emission = 0.0;
    }

    // Only apply effects if we detected a clear flower AND emission is reasonable
    if (emission > 0.0 && emission < 1.0) { // Strict cap - no intense glows
        // Very calm, barely noticeable breathing effect
        vec3 worldPosFlower = playerPos + cameraPosition;
        float timeNoise = sin(frameTimeCounter * 0.5 + dot(worldPosFlower.xz, vec2(12.9898, 78.233))) * 0.5 + 0.5;
        timeNoise = timeNoise * 0.02 + 0.98; // Almost static, clean look
        emission *= timeNoise;

        // Very slight night enhancement - keep it magical but subtle
        float timeOfDay = sunAngle;
        float isNight = float(timeOfDay > 0.52 && timeOfDay < 0.98);
        float nightFactor = 1.0 + isNight * 0.08; // Very gentle night boost
        emission *= nightFactor;

        // Distance-based fade - gentle and natural
        float distanceFactor = 1.0 - min(lViewPos / 32.0, 0.8); // Close-range only
        emission *= (0.4 + 0.6 * distanceFactor); // Conservative falloff

        materialMask = 0.0; // No SSAO for glowing flowers
    } else {
        // Force no emission for anything that doesn't clearly match flower criteria
        emission = 0.0;
    }
}
