#!/system/bin/sh
# KSU Manager 里点「Action」：立即重设开关并结束 mirror 进程，
# 让下次妙享桌面连接按新的 SDR 编码配置重新初始化。
MODDIR=${0%/*}
. "$MODDIR/common.sh"

echo "========== 妙享桌面 HDR 修复 - 立即应用 =========="

if [ -z "$RESETPROP" ]; then
    echo "[错误] 未找到 resetprop，请确认 KernelSU 正常安装。"
    exit 1
fi

echo "[1/3] 修改前属性："
for p in $TARGET_PROPS; do
    echo "      $p = $(getprop "$p" 2>/dev/null)"
done

apply_fix

echo "[2/3] 修改后属性："
for p in $TARGET_PROPS; do
    echo "      $p = $(getprop "$p" 2>/dev/null)"
done

echo "[3/3] 结束 com.miui.mirror 进程以便下次重新初始化…"
am force-stop com.miui.mirror 2>/dev/null
am force-stop com.xiaomi.mirror 2>/dev/null
echo "      完成。现在回到平板重新发起「妙享桌面手机」连接即可。"

echo "=================================================="
exit 0
