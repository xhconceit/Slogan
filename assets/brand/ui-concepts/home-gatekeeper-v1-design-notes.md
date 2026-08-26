# 小门卫首页与加载动画 V1

## 首页生成方式

- 工具：Codex 内置图像生成
- 角色参考：`../C1-gatekeeper-character-transparent.png`
- 输出：`home-gatekeeper-locked-v1.png`

## 首页最终提示词

```text
Use case: ui-mockup
Asset type: high-fidelity portrait mobile app home screen
Input images: Image 1 is the exact mascot identity reference. Integrate this same full blue-and-cream gatekeeper character into the main status card without redesigning its body, face, colors, arms, feet, proportions, or subtle surface treatment.
Primary request: Design a polished, implementation-ready home screen for the Chinese mobile self-discipline app “再玩”. The product rule is: all of today's tasks must be completed before selected entertainment apps unlock. Show a realistic locked state with two tasks remaining out of three.
Style/medium: realistic modern mobile product UI, calm, friendly, focused and slightly playful; suitable for implementation in Flutter; not concept art and not a physical phone mockup.
Canvas/composition: one complete tall portrait phone screen, edge-to-edge UI, approximately 9:19.5. Respect top and bottom safe areas. Clear vertical hierarchy, generous whitespace, large touch targets.
Brand palette: cobalt blue #2F64C5 as primary; warm cream #FFF0CF; warm off-white #F8F6F1 page background; pale blue #E7EEFB; warm orange #E87448 as the “完成后去玩” reward accent; dark navy #1F2E46 for primary text; soft blue-gray secondary text. No teal or coral.
Typography: clean modern Chinese sans-serif, accurate characters, excellent readability, no tiny text.
Layout:
1. Compact system status bar.
2. Header showing the date on one line and “早上好” beneath, with a small circular profile/settings button on the right.
3. A large rounded pale-blue status card inspired by a friendly doorway. Left side: progress and locked-state copy. Right side: the exact mascot from Image 1, fully visible but small enough not to cover text. Include one clean horizontal progress bar. Use orange only to emphasize the number “2”.
4. “今日任务” section heading with a compact rounded plus button.
5. Three spacious white rounded task cards: a focus-timer task currently in progress with a blue filled “继续” button; a pending manual task with an outlined “完成” button; and a completed task with a blue check and softened text.
6. Bottom navigation with three items; “今日” is selected in cobalt blue.
Text (verbatim): "8月27日 星期四", "早上好", "还差 2 项", "完成全部任务，打开娱乐之门", "受限 App 已锁定", "1 / 3", "今日任务", "背单词", "15 / 30 分钟", "继续", "完成数学试卷", "手动任务", "完成", "整理书桌", "已完成", "今日", "任务", "设置".
Constraints: render every listed Chinese phrase accurately and do not invent extra body copy. Keep mascot identity unchanged. Practical spacing and alignment, 20–24 px corner radius, restrained shadows, accessible contrast. Do not add streaks, coins, rankings, social features, analytics charts, AI features, photographs, gradients, glassmorphism, excessive decoration, watermarks, external branding, or a physical device frame.
```

## 加载动画规格

- 角色源：`../C1-gatekeeper-character-transparent.png`
- 画布：512 × 512，透明背景
- 帧数：12
- 帧间隔：80 ms
- 单次循环：约 0.96 秒
- 动作：角色在 342–360 px 之间轻微呼吸缩放，并上下浮动 18 px；下方三个暖橙圆点依次脉冲
- 品牌色：钴蓝角色、暖奶油腹部、暖橙 `#E87448` 状态点
- 输出：透明 GIF、动画 WebP、4 × 3 精灵图

动画采用确定性的图像变换制作，没有逐帧 AI 重绘，因此角色轮廓与表情不会漂移。
