#!/system/bin/sh
# 公共逻辑：定位 resetprop，并将妙享桌面投屏的 HDR/P3 编码开关置为 false

# 定位 resetprop（KernelSU / APatch / Magisk 兼容）
find_resetprop() {
    if command -v resetprop >/dev/null 2>&1; then
        command -v resetprop
    elif [ -x /data/adb/ksu/bin/resetprop ]; then
        echo /data/adb/ksu/bin/resetprop
    elif [ -x /data/adb/ap/bin/resetprop ]; then
        echo /data/adb/ap/bin/resetprop
    elif [ -x /data/adb/magisk/resetprop ]; then
        echo /data/adb/magisk/resetprop
    else
        echo ""
    fi
}

RESETPROP="$(find_resetprop)"

# 需要置为 false 的编码开关
TARGET_PROPS="debug.config.video.hevchdr10.encode.support debug.config.video.p3.encode.support"

# 原始默认值（用于卸载时恢复）
restore_original() {
    [ -n "$RESETPROP" ] || return 1
    "$RESETPROP" -n debug.config.video.hevchdr10.encode.support true >/dev/null 2>&1
    "$RESETPROP" -n debug.config.video.p3.encode.support true >/dev/null 2>&1
}

# 立即应用：把所有目标开关改为 false
apply_fix() {
    [ -n "$RESETPROP" ] || return 1
    for p in $TARGET_PROPS; do
        "$RESETPROP" -n "$p" false >/dev/null 2>&1
    done
}

# 当前是否所有目标开关都为 false
all_false() {
    for p in $TARGET_PROPS; do
        v="$(getprop "$p" 2>/dev/null)"
        [ "$v" = "false" ] || return 1
    done
    return 0
}
