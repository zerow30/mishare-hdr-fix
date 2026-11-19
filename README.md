# 妙享桌面投屏灰屏闪退修复

一个 KernelSU 模块，用于修复 Root 环境下「妙享桌面 / 手机投屏」连接时投屏窗口灰屏、短暂后闪退的问题。

## 问题表现

在已 Root 的设备上，从平板端发起「妙享桌面手机」后，投屏窗口显示灰屏与「正在连接」，数秒后崩溃退出，连接失败。

## 原因分析

故障时段（09:48–09:49）的 logcat 显示，每次连接时 `com.miui.mirror` 的 `ScreenHardEncoder` 都以 HDR10 参数启动高通编码器，随后编码失败：

```
mUseGamutHdr true
createMediaFormat { mime=video/hevc, profile=2, color-standard=6, color-transfer=6 }  # HEVC Main10 / BT.2020 / PQ
createByCodecName: c2.qti.hevc.encoder
→ MediaCodec$CodecException: Error 0x80000000  (at MediaCodec.setParameters)
→ display_failure_observed stage=encoder reason=media_codec_error
```

同一时段的日志还显示，连接建立阶段平板 HDR 能力探测未返回有效结果（`isPadAndSupportHDR` 返回 `display == null` / `deviceId == null`），但编码策略仍判定启用 HDR 编码。在能力未确认的情况下使用 HDR10 参数，是编码失败的直接触发条件。

> 说明：现有日志只能证明上述现象与 Root 状态存在时间关联，无法定位到具体是哪个组件或哪个 hook 导致能力探测未返回有效结果。本项目不对任何第三方模块或应用作责任判断。

## 修复原理

模块在开机阶段将以下两个投屏编码开关置为 `false`：

| 属性 | 作用 |
| --- | --- |
| `debug.config.video.hevchdr10.encode.support` | HDR10 视频编码 |
| `debug.config.video.p3.encode.support` | P3 广色域视频编码 |

编码器因此回退到 SDR 配置（`profile=1` / BT.709），避开高通编码器对 HDR10 参数的拒绝。解码开关 `p3.decode.support` 不改动。

模块不修改任何 `/system` 文件，仅在属性层生效。`service.sh` 中带有看门狗，防止属性被系统服务改回。卸载时会自动将两个属性恢复为原厂默认值 `true`，无需手动清理。

## 安装与使用

1. 在 KernelSU Manager 中安装模块 zip，重启。
2. 终端验证：

   ```sh
   getprop debug.config.video.hevchdr10.encode.support
   getprop debug.config.video.p3.encode.support
   ```

   两者均应为 `false`。

3. 若个别情况连接仍失败，可在模块页点击 **Action** 按钮（重设开关并结束 `com.miui.mirror` 进程）后重试。

## 显示效果

- **本机**：本地播放、显示 HDR 内容不受影响，仍按 HDR 输出。模块只作用于投屏编码链路，不介入本地显示。
- **平板**：妙享桌面为整屏编码投屏，模块生效后平板接收的是 SDR 视频流。手机端为 HDR 的视频或图片，在平板端将以 SDR 呈现，动态范围与广色域有所损失。这是预期行为——未修复前该场景下 HDR 编码会失败并导致连接崩溃。

## 适用范围与限制

- 需 Root 环境（KernelSU；脚本同时兼容 APatch / Magisk 的 resetprop 路径）。
- 不同机型的编码链路与属性定义可能存在差异，使用前可先通过 `getprop` 确认上述属性是否存在。本模块不保证对所有机型生效。
- 本模块仅针对上述 HDR 编码失败场景，不处理系统完整性校验或设备认证相关的其他问题。

## 免责声明

本模块按「原样」提供，不附带任何明示或暗示的保证。使用者应自行判断风险并承担使用后果。本项目与相关设备厂商、系统及第三方模块开发者无关联，亦不对其产品行为作评价或责任判断。
