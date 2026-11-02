void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord / iResolution.xy;
  vec4 term = texture(iChannel0, uv);
  float n = 72.0;
  float i = floor(uv.x * n);
  float x = fract(uv.x * n);
  float t = iTime;
  float h = 0.03 + 0.10 * (0.5 + 0.5 * sin(t * 2.1 + i * 0.7)) * (0.5 + 0.5 * sin(t * 1.3 + i * 0.23));
  h += 0.04 * (0.5 + 0.5 * sin(t * 3.7 + i * 1.9));
  h *= 0.65 + 0.35 * sin(i * 0.12 + t * 0.4);
  float y = 1.0 - uv.y;
  float inBar = step(y, h) * step(0.18, x) * step(x, 0.82);
  vec3 c1 = vec3(0.29, 0.36, 1.00);
  vec3 c2 = vec3(0.69, 0.49, 1.00);
  vec3 c3 = vec3(1.00, 0.31, 0.64);
  vec3 c4 = vec3(1.00, 0.42, 0.29);
  float g = uv.x * 3.0;
  vec3 col = g < 1.0 ? mix(c1, c2, g) : (g < 2.0 ? mix(c2, c3, g - 1.0) : mix(c3, c4, g - 2.0));
  float glow = inBar * 0.16 * (1.0 - 0.6 * y / max(h, 0.001));
  fragColor = vec4(term.rgb + col * glow, term.a);
}
