妙享桌面投屏灰屏闪退修复（KernelSU 模块）
==========================================

作用
----
修复 Root 环境下，妙享桌面投屏时手机侧 ScreenHardEncoder 用 HDR10 参数
(HEVC Main10 / BT.2020 / PQ) 启动高通编码器 c2.qti.hevc.encoder，
被 setParameters 拒绝(0x80000000)，导致投屏灰屏、平板窗口闪退的问题。

原理
----
把两个投屏编码开关置为 false，让编码器回退到 SDR(HEVC Main/BT.709)：
  debug.config.video.hevchdr10.encode.support = false
  debug.config.video.p3.encode.support        = false
解码开关 p3.decode.support 不动，不影响其他视频功能。

安装
----
1. 把本模块 zip 通过 KSU Manager -> 模块 -> 从本地安装 刷入。
2. 重启手机。开机后 post-fs-data / service / boot-completed 三个阶段
   都会设置开关，service.sh 的看门狗还会防止系统服务把值改回 true。

使用
----
- 正常情况：重启后直接去平板发起妙享桌面连接即可。
- 如果某次仍失败：打开 KSU Manager -> 本模块 -> Action 按钮，
  它会重新设置开关并结束 com.miui.mirror 进程，然后你再发起一次连接。

验证是否生效（手机 adb shell / 终端）：
  getprop debug.config.video.hevchdr10.encode.support
  getprop debug.config.video.p3.encode.support
  两者都应为 false。

显示效果
--------
- 本机：本地播放、显示 HDR 内容不受影响，仍按 HDR 输出。模块只作用于投屏编码链路。
- 平板：投屏接收的是 SDR 视频流，手机端为 HDR 的内容在平板端将以 SDR 呈现，
  动态范围与广色域有损失，属预期行为。

注意
----
- 卸载模块时会自动把上述属性恢复为 true（原厂默认），无需手动清理。
- 本模块不修改任何 /system 文件，纯属性层修复，可随时停用/卸载。
- 本模块仅针对上述 HDR 编码失败场景，不处理系统完整性校验或设备认证相关的
  其他问题；不对任何第三方模块或应用作责任判断。
- 不同机型的编码链路与属性定义可能存在差异，不保证对所有机型生效。
