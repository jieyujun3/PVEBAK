#!/bin/bash
# PVE Ultimate 一键优化 & 工具脚本 by jieyujun3
# 功能：国内源、企业源、去订阅弹窗、系统更新、安装 Ceph、ZFS 支持、常用工具

set -e

PVE_SOURCE_FILE="/etc/apt/sources.list"
PVE_ENTERPRISE_LIST="/etc/apt/sources.list.d/pve-enterprise.list"
PVE_CEPH_LIST="/etc/apt/sources.list.d/ceph.list"
JS_FILE="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"

backup_sources() {
  cp -f "$PVE_SOURCE_FILE" "$PVE_SOURCE_FILE.bak"
  [ -f "$PVE_ENTERPRISE_LIST" ] && cp "$PVE_ENTERPRISE_LIST" "$PVE_ENTERPRISE_LIST.bak"
  echo "\n✅ 已备份源配置"
}

change_to_china_sources() {
  echo -e "\n🌐 选择国内源："
  echo "1) 清华"
  echo "2) 中科大"
  echo "3) 阿里"
  echo "4) 华为"
  read -p "选择 [默认1]: " opt
  case $opt in
    2) base_url="http://mirrors.ustc.edu.cn";;
    3) base_url="http://mirrors.aliyun.com";;
    4) base_url="https://mirrors.huaweicloud.com";;
    *) base_url="https://mirrors.tuna.tsinghua.edu.cn";;
  esac

  cat > "$PVE_SOURCE_FILE" <<EOF
deb $base_url/debian bookworm main contrib non-free non-free-firmware
deb $base_url/debian bookworm-updates main contrib non-free non-free-firmware
deb $base_url/debian-security bookworm-security main contrib non-free non-free-firmware
EOF

  echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
  apt update
  echo "✅ 国内源切换完成"
}

enable_enterprise_sources() {
  echo "deb https://enterprise.proxmox.com/debian/ceph-quincy bookworm enterprise" > "$PVE_CEPH_LIST"
  apt update
  echo "✅ 企业 Ceph 源设置完成"
}

remove_subscription_notice() {
  if grep -q "No valid subscription" "$JS_FILE"; then
    sed -i.bak "/.*No valid subscription/,+10 s/Ext.Msg.show.*//g" "$JS_FILE"
    echo "✅ 去除订阅弹窗成功 (如无效请清缓存/重启pveproxy)"
  else
    echo "订阅弹窗代码未找到或已去除"
  fi
}

update_system() {
  apt update && apt full-upgrade -y
  echo "✅ 系统更新完成"
}

install_ceph() {
  echo "\n🚀 安装 Ceph (Quincy) ..."
  pveceph install --version 17
  echo "✅ Ceph 安装完成"
}

install_zfs_tools() {
  echo "\n🚀 安装 ZFS 支持工具 ..."
  apt install -y zfsutils-linux zfs-zed
  echo "✅ ZFS 工具安装完成"
}

install_common_tools() {
  echo "\n🚀 安装常用工具 ..."
  apt install -y htop iftop iotop smartmontools lshw lm-sensors curl vim git
  echo "✅ 常用工具安装完成"
}

while true; do
  echo -e "\n=========== 🚀 PVE Ultimate 工具菜单 ==========="
  echo "1) 切换国内源"
  echo "2) 设置企业 Ceph 源"
  echo "3) 去除订阅登录弹窗"
  echo "4) 系统更新"
  echo "5) 安装 Ceph (17 Quincy)"
  echo "6) 安装 ZFS 支持"
  echo "7) 安装常用工具 (htop 等)"
  echo "8) 退出"
  echo "==========================================="
  read -p "请选择操作 [1-8]: " action
  case $action in
    1) backup_sources; change_to_china_sources;;
    2) enable_enterprise_sources;;
    3) remove_subscription_notice;;
    4) update_system;;
    5) install_ceph;;
    6) install_zfs_tools;;
    7) install_common_tools;;
    8) echo "退出"; exit 0;;
    *) echo "无效选择，请输入1-8";;
  esac
done
