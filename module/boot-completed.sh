#!/system/bin/sh
# 开机完成后再兜底设置一次（部分属性在 late_start 之后才被置位）
MODDIR=${0%/*}
. "$MODDIR/common.sh"

apply_fix
exit 0
