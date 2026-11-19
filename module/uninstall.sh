#!/system/bin/sh
# 卸载时恢复属性为原厂默认值 true，保持系统原始行为
MODDIR=${0%/*}
. "$MODDIR/common.sh"

restore_original
exit 0
