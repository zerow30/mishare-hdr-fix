#!/system/bin/sh
# 开机早期（post-fs-data）设置一次，尽量早于 mirror 进程读取属性
MODDIR=${0%/*}
. "$MODDIR/common.sh"

apply_fix
exit 0
