#!/bin/bash
# PVE 本地虚拟机配置恢复脚本
# 作者: jieyujun3
# 用于重装系统后，恢复本地VM配置和镜像目录结构

set -e

echo "[1/4] 检查 root 权限..."
if [[ $EUID -ne 0 ]]; then
   echo "请使用 root 用户执行此脚本！"
   exit 1
fi

echo "[2/4] 恢复虚拟机配置到 /etc/pve/qemu-server/"
if [ -d ./qemu-server ]; then
    cp -rv ./qemu-server/*.conf /etc/pve/qemu-server/
else
    echo "未找到 ./qemu-server 文件夹，请先将 VM 配置文件复制到当前目录"
    exit 1
fi

echo "[3/4] 检查并创建镜像目录 /var/lib/vz/images/"
mkdir -p /var/lib/vz/images/

echo "[4/4] 恢复完成，请手动挂载或确认镜像是否完整"
echo "可以使用 qm list 检查 VM 是否识别"
