#!/system/bin/sh
# late_start service：先设置一次，再起看门狗防止被系统服务改回 true
MODDIR=${0%/*}
. "$MODDIR/common.sh"

apply_fix

# 看门狗：每 4 秒检查一次，发现被改回 true 就重设。
# 只在值错误时才写属性，空闲开销极低。
(
    while true; do
        sleep 4
        if ! all_false; then
            apply_fix
        fi
    done
) &
