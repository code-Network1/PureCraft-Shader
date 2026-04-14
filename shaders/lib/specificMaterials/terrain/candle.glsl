// Candle rendering — smooth lighting KEPT ON to prevent noise from lightmap x^3 formula
// noSmoothLighting was the root cause: pow2(x)*x*10 amplifies tiny per-pixel variations into visible noise

// Add a stable warm emission so the flame always glows cleanly
emission = max(emission, 0.12);

// Brightness gradient: top of candle wax brighter, bottom dimmer
color.rgb *= 1.0 + 0.5 * pow2(max(-signMidCoordPos.y + 0.6,
                                   float(NdotU > 0.9) * 1.6));

#ifdef SNOWY_WORLD
    snowFactor = 0.0;
#endif
