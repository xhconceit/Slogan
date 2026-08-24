# Android 平台能力

## 1. 当前验证状态

Android App 控制仍处于 PoC 阶段，尚未确定为稳定的生产方案。

已验证两种前台 App 识别方式：

1. `AccessibilityService` 窗口事件。
2. 前台服务中通过 `UsageStatsManager` 定时查询。

已在一台小米 HyperOS 真机上验证第三项辅助条件：用户授权 `SYSTEM_ALERT_WINDOW` 后，由前台服务显示一个不可触摸的小型 `TYPE_APPLICATION_OVERLAY`。A/B/A 对照结果为：

1. 显示悬浮窗时，检测器实时识别到浏览器并成功执行 Home。
2. 只关闭悬浮窗、保持无障碍服务 Enabled/Bound 和前台服务运行时，系统确认浏览器在前台，但 PoC 的检测结果仍停留在系统桌面，未执行 Home。
3. 重新显示悬浮窗后，再次实时识别浏览器并成功执行 Home。

两次成功记录的检测来源均为 `AccessibilityService.rootInActiveWindow`，执行 `GLOBAL_ACTION_HOME` 的返回值均为 `true`。这说明悬浮窗在该设备上改变了窗口信息或进程可见性相关行为，但尚不能据此判断具体系统机制，也不能推广到其他 HyperOS 或 Android 设备。

悬浮窗本身不具备识别前台 App 的能力，因此只作为该设备上的运行辅助条件和检测成功后的拦截界面候选，不作为检测器。

## 2. AccessibilityService

标准 Pixel 模拟器可以在控制 App 进入后台后持续收到其他 App 的无障碍事件。

在已测试的小米 HyperOS 真机上，即使服务保持 `Enabled` 和 `Bound`，且进程未被冻结，其他 App 的事件仍可能在后台积压，并在控制 App 返回前台后批量派发。

测试过但未解决该问题的配置包括：

- 后台自启动
- `TYPE_WINDOW_STATE_CHANGED`
- `TYPE_WINDOWS_CHANGED`
- `TYPES_ALL_MASK`
- `FLAG_RETRIEVE_INTERACTIVE_WINDOWS`
- 常驻前台服务

因此，不得假设 `AccessibilityService` 能在所有 Android 厂商设备上可靠、实时地识别前台 App。

## 3. UsageStatsManager 轮询

在小米 HyperOS 真机上，常驻前台服务每 500 毫秒主动检查前台 App。当前实现优先读取 `AccessibilityService.rootInActiveWindow`，不可用时回退到 `UsageStatsManager.queryEvents`。

仅使用最近 3 秒的 `UsageStatsManager` 事件并不可靠：目标 Activity 已在运行、任务被复用或服务重启后，当前前台 App 可能没有新的 `ACTIVITY_RESUMED` 事件。

PoC 已进一步验证以下控制闭环：

1. 前台服务通过 `UsageStatsManager` 检测到受限浏览器。
2. 已连接的 `AccessibilityService` 执行 `GLOBAL_ACTION_HOME`。
3. 浏览器在约一个轮询周期后返回系统桌面。
4. 连续两次打开受限浏览器均成功返回桌面。
5. 未列入受限列表的微信保持前台，但该次测试没有证明微信包名能被轮询稳定识别。

该方式不是停止、卸载或从系统层禁止目标 App，而是在检测到目标 App 进入前台后执行 Home。

当前 PoC 参数：

- 查询间隔：500 毫秒
- 查询窗口：最近 3 秒
- 只在检测到的包名变化时写入状态

该方案仍需继续验证：

- 实际检测延迟
- 长时间后台稳定性
- 耗电量
- 锁屏、重启及系统回收后的行为
- 不同厂商和 Android 版本兼容性
- 前台服务通知的用户体验
- 轮询检测与执行 Home 之间的实际延迟分布
- 前台 App 已经处于运行状态、Activity 复用等场景的识别可靠性
- `rootInActiveWindow` 对不同 App、受保护窗口和厂商系统的可用性
- 悬浮窗辅助效果在设备重启、锁屏和长时间后台后的持续性
- 悬浮窗辅助效果在其他 HyperOS 版本、厂商及 Android 版本上的可重复性

## 4. 权限与发布限制

当前 PoC 使用：

- `PACKAGE_USAGE_STATS`
- `BIND_ACCESSIBILITY_SERVICE`
- `FOREGROUND_SERVICE`
- `FOREGROUND_SERVICE_SPECIAL_USE`
- `POST_NOTIFICATIONS`
- `SYSTEM_ALERT_WINDOW`（当前仅用于悬浮窗诊断实验）

`AccessibilityService` 不是普通后台控制权限。若产品并非帮助残障人士使用设备，不得声明为 accessibility tool，并需要满足 Google Play 的显著披露、用户同意和权限声明要求。

`specialUse` 前台服务需要在 Manifest 中说明具体用途，并会在发布时接受 Google Play 审核。

`SYSTEM_ALERT_WINDOW` 需要用户在系统设置中单独授权，可能被用户撤销或受厂商系统限制。当前诊断悬浮窗不可触摸，避免拦截其他 App 的输入。

## 5. 当前结论

V1 不应仅依赖 `AccessibilityService` 事件实现 Android App 控制。

`UsageStatsManager` 前台轮询加 `AccessibilityService` 全局 Home 操作已在 Pixel 模拟器和一台小米 HyperOS 真机上完成最小控制闭环。

在当前小米 HyperOS 测试机上，常驻不可触摸悬浮窗是实现实时检测的必要实验条件。该方案在完成长时间稳定性、耗电、更多设备兼容性、悬浮窗用户体验和发布合规验证前，不视为最终架构。

## 6. 无障碍替代实验

当前 PoC 增加 `UsageStatsManager + TYPE_APPLICATION_OVERLAY` 模式，用于验证不启用无障碍服务时的完整闭环：

1. 前台服务持续读取 `UsageEvents.Event.ACTIVITY_RESUMED`。
2. 服务保存最后一次已知前台包名，避免固定的短查询窗口在没有新事件时立即丢失状态。
3. 检测到受限浏览器后，将状态圆点替换成可触摸的全屏锁定悬浮层。
4. 用户点击锁定层后通过普通 Home Intent 返回桌面，不调用无障碍全局操作。

该模式仍依赖使用情况访问权限、悬浮窗权限和前台服务。

已在当前小米 HyperOS 真机上完成首次闭环验证：系统无障碍服务的 Enabled/Bound 列表均为空，浏览器仍被 `UsageStatsManager` 检测到，记录的检测来源为 `usage_stats`，随后成功显示全屏锁定悬浮层。由此确认该次控制不依赖无障碍服务或其残留连接。

仍需验证重复打开已存在的浏览器任务、不同入口跳转、长时间后台、锁屏、重启及厂商进程回收后的检测可靠性。
