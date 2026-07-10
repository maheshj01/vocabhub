#version 460 core
#include <flutter/runtime_effect.glsl>

// Animated "mesh gradient" page background.
//
// Renders a base surface colour overlaid with a few soft, slowly drifting
// colour blobs. All the softness comes from smoothstep falloff on the GPU, so
// there is no CPU mask blur and no full-screen BackdropFilter — the whole thing
// is one fragment pass. Replaces the old CPU BackgroundPainter + BackdropFilter.

precision mediump float;

uniform vec2 uSize;       // canvas size in px
uniform float uTime;      // seconds, drives the drift
uniform vec4 uPrimary;    // colorScheme.primary
uniform vec4 uSecondary;  // colorScheme.inversePrimary
uniform vec4 uBase;       // surface / background colour

out vec4 fragColor;

// Soft radial blob: 1.0 at the centre, easing to 0.0 at radius r.
float blob(vec2 uv, vec2 center, float r) {
  float d = distance(uv, center);
  return smoothstep(r, 0.0, d);
}

void main() {
  // Normalised, aspect-corrected coordinates so blobs stay circular.
  vec2 uv = FlutterFragCoord().xy / uSize;
  float aspect = uSize.x / uSize.y;
  vec2 p = vec2(uv.x * aspect, uv.y);
  float cx = aspect * 0.5;

  float t = uTime;

  // Three centres drifting along gentle Lissajous paths.
  vec2 c1 = vec2(cx + 0.30 * sin(t * 0.35),        0.32 + 0.18 * cos(t * 0.45));
  vec2 c2 = vec2(cx + 0.34 * cos(t * 0.27 + 1.0),  0.68 + 0.22 * sin(t * 0.31 + 2.0));
  vec2 c3 = vec2(cx + 0.26 * sin(t * 0.21 + 3.0),  0.50 + 0.28 * cos(t * 0.18));

  float b1 = blob(p, c1, 0.60);
  float b2 = blob(p, c2, 0.65);
  float b3 = blob(p, c3, 0.55);

  vec3 col = uBase.rgb;
  col = mix(col, uPrimary.rgb,   b1 * 0.55);
  col = mix(col, uSecondary.rgb, b2 * 0.55);
  col = mix(col, uPrimary.rgb,   b3 * 0.35);

  fragColor = vec4(col, 1.0);
}
