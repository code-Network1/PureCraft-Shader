if (color.a > 0.001) {
    smoothnessG = 1.0;
    highlightMult = 3.5;
    reflectMult = 0.5;

    translucentMultCalculated = true;
    translucentMult = vec4(0.0, 0.0, 0.0, 1.0);
} else {
        //discard;
}
