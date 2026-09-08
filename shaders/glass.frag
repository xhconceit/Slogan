#include <flutter/runtime_effect.glsl>

uniform vec2 u_size;
uniform float u_strength;
uniform sampler2D u_texture;

out vec4 frag_color;

void main() {
  vec2 pixel = FlutterFragCoord().xy;
  vec2 center = u_size * 0.5;
  vec2 p = pixel - center;

  // 胶囊由中间的矩形和左右两个半圆组成。
  float radius = min(u_size.x, u_size.y) * 0.5;
  float halfLine = max(u_size.x * 0.5 - radius, 0.0);

  // 找到胶囊中轴线上距离当前像素最近的点。
  vec2 nearest = vec2(
    clamp(p.x, -halfLine, halfLine),
    0.0
  );

  vec2 delta = p - nearest;
  float distanceToLine = length(delta);

  // 指向胶囊外侧的方向。
  vec2 normal = delta / max(distanceToLine, 0.001);

  // 内部为正，轮廓处为 0。
  float insideDistance = radius - distanceToLine;

  // 折射只发生在靠近轮廓的一圈。
  float edgeWidth = max(radius * 0.45, 1.0);
  float edgePosition = clamp(
    insideDistance / edgeWidth,
    0.0,
    1.0
  );

  // 最外沿和内部都归零，中间平滑隆起。
  float bend = sin(edgePosition * 3.14159265);

  // 向内部采样，制造边缘背景被拉伸的效果。
  float displacement = bend * u_strength * radius;
  vec2 samplePixel = pixel - normal * displacement;

  vec2 sampleUV = samplePixel / u_size;

#ifdef IMPELLER_TARGET_OPENGLES
  sampleUV.y = 1.0 - sampleUV.y;
#endif

  // 限制在纹理像素中心范围内，避免边界采样异常。
  vec2 inset = vec2(0.5) / u_size;
  sampleUV = clamp(sampleUV, inset, vec2(1.0) - inset);

  // 底栏高度为 66 个逻辑像素，换算约 1.2 个逻辑像素的柔化半径。
  float blurPixels = 1.2 * u_size.y / 66.0;
  vec2 dx = vec2(blurPixels / u_size.x, 0.0);
  vec2 dy = vec2(0.0, blurPixels / u_size.y);

  // 五点采样的权重之和为 1，保持背景亮度与预乘透明度。
  vec4 color = texture(u_texture, sampleUV) * 0.50;
  color += texture(
    u_texture,
    clamp(sampleUV + dx, inset, vec2(1.0) - inset)
  ) * 0.125;
  color += texture(
    u_texture,
    clamp(sampleUV - dx, inset, vec2(1.0) - inset)
  ) * 0.125;
  color += texture(
    u_texture,
    clamp(sampleUV + dy, inset, vec2(1.0) - inset)
  ) * 0.125;
  color += texture(
    u_texture,
    clamp(sampleUV - dy, inset, vec2(1.0) - inset)
  ) * 0.125;

  frag_color = color;
}
