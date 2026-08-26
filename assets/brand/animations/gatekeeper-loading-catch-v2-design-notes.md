# 小门卫接球加载动画 V2

## 设计概念

小门卫闭眼微笑，用双手来回抛接一颗暖橙色小球。球越过头顶时，角色轻轻起跳；球靠近左手或右手时，身体随之侧倾。

## 动画规格

- 画布：512 × 512
- 帧数：24
- 帧间隔：70 ms
- 循环时长：约 1.68 秒
- 角色：钴蓝与暖奶油
- 小球：暖橙 `#E87448`，带暖奶油高光
- 正式资产：透明 GIF、透明动画 WebP
- 预览资产：暖米白背景 GIF

角色动作采用同一个关键姿势进行确定性旋转和位移，没有逐帧 AI 重绘。

## 关键姿势生成方式

工具：Codex 内置图像生成。

```text
Use case: identity-preserve
Asset type: transparent mascot key pose for a cute looping loading animation
Input images: Image 1 is the sole character identity anchor.
Primary request: Create one playful “ready to catch a tiny ball” pose of the exact same blue-and-cream gatekeeper mascot from Image 1. Lift both short rounded arms slightly upward and outward like the character is eagerly waiting to catch something. Lift both tiny feet just a little so the pose feels buoyant and bouncy.
Expression: change only the expression to two small warm-cream closed crescent eyes and one slightly wider warm-cream delighted smile. Make the emotion sweet, innocent, calm and genuinely cute, not loud or hyperactive.
Character invariants: preserve the exact cobalt-blue rounded arch body, large warm creamy-ivory doorway-shaped belly region, compact proportions, two short thick rounded arms, two tiny rounded feet, ultra-clean surfaces, and extremely subtle soft dimensionality of Image 1. Do not change body shape, belly shape, color families, or identity.
Composition: one complete upright front-facing full-body character centered on a genuine transparent square canvas with even padding and nothing cropped. Leave generous empty transparent space above the raised hands for a separately animated ball.
Style: minimal polished mobile-product mascot, soft rounded geometric forms, baby-like appeal, simple strong silhouette.
Constraints: genuine transparent background with alpha. Include the mascot only; do not draw the ball or any prop. No colored backdrop, white background, checkerboard pattern, floor, cast shadow, outline, text, watermark, clothing, fingers, nose, eyebrows, cheeks, teeth, tongue, extra limbs, scenery, decorative marks, sharp corners, or thin lines.
```
