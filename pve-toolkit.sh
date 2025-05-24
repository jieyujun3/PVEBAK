#!/bin/bash

# Define backup and restore directories
BACKUP_DIR="/root/pvebak"
VM_CONF_BACKUP="/root/pvebak/vm_backup"

# Ensure backup directories exist
mkdir -p "$BACKUP_DIR" "$VM_CONF_BACKUP"

function show_main_menu() {
    clear
    echo "========= PVE 工具箱 ========="
    echo "1. 国内源与企业订阅优化"
    echo "2. 系统网络配置"
    echo "3. 备份与还原工具"
    echo "4. 常用工具安装"
    echo "5. 常用命令功能"
    echo "6. 退出"
    echo "=============================="
    read -p "请选择功能 [1-6]: " choice

    case $choice in
        1) optimize_sources ;;
        2) network_config ;;
        3) backup_restore_menu ;;
        4) install_tools_menu ;;
        5) common_cmd_menu ;;
        6) exit 0 ;;
        *) echo "无效选项，请重新选择。"; sleep 2; show_main_menu ;;
    esac
}

function optimize_sources() {
    echo "更换国内源..."
    sed -i.bak 's|http://download.proxmox.com|https://mirrors.tuna.tsinghua.edu.cn/proxmox|' /etc/apt/sources.list
    echo "去除企业订阅..."
    sed -i.bak '/enterprise/s/^/#/' /etc/apt/sources.list.d/pve-enterprise.list
    echo "去除订阅提醒..."
    cat <<EOF > /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
Ext.Msg.show=function(){};
EOF
    echo "更新系统..."
    apt update && apt -y full-upgrade
    echo "完成！"
    read -p "按回车返回主菜单..." temp
    show_main_menu
}

function network_config() {
    echo "==== 网络配置 ===="
    read -p "请输入新的IP地址（如192.168.1.100/24）: " ipaddr
    read -p "请输入网关地址: " gateway
    read -p "请输入要配置的网卡名（如ens18）: " iface
    cat <<EOF > /etc/network/interfaces
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto $iface
iface $iface inet static
    address $ipaddr
    gateway $gateway
EOF
    echo "网络配置已更新。请手动重启网络或系统使其生效。"
    read -p "按回车返回主菜单..." temp
    show_main_menu
}

function backup_restore_menu() {
    clear
    echo "===== 备份与还原 ====="
    echo "1. 备份 PVE 配置 (/etc)"
    echo "2. 还原 PVE 配置"
    echo "3. 备份 VM 配置 (/etc/pve/qemu-server)"
    echo "4. 还原 VM 配置"
    echo "5. 返回主菜单"
    read -p "请选择操作 [1-5]: " opt

    case $opt in
        1) cp -r /etc "$BACKUP_DIR" && echo "配置已备份至 $BACKUP_DIR" ;;
        2) cp -r "$BACKUP_DIR/etc"/* /etc/ && echo "配置已还原。请检查系统服务是否正常。" ;;
        3) cp -r /etc/pve/qemu-server "$VM_CONF_BACKUP" && echo "VM配置已备份。" ;;
        4) cp -r "$VM_CONF_BACKUP/qemu-server" /etc/pve/ && echo "VM配置已还原。" ;;
        5) show_main_menu ;;
        *) echo "无效选项..." ;;
    esac
    read -p "按回车返回..." temp
    backup_restore_menu
}

function install_tools_menu() {
    echo "===== 常用工具安装 ====="
    echo "1. 安装 iftop"
    echo "2. 安装 htop"
    echo "3. 安装 nfs-common"
    echo "4. 返回主菜单"
    read -p "请选择要安装的工具 [1-4]: " toolopt

    case $toolopt in
        1) apt install -y iftop ;;
        2) apt install -y htop ;;
        3) apt install -y nfs-common ;;
        4) show_main_menu ;;
        *) echo "无效选项..." ;;
    esac
    read -p "按回车继续..." temp
    install_tools_menu
}

function common_cmd_menu() {
    echo "===== 常用命令功能 ====="
    echo "1. 查看磁盘分区 (lsblk)"
    echo "2. 挂载共享磁盘 (手动输入)"
    echo "3. 查看网卡信息 (ip a)"
    echo "4. 重新加载网络 (systemctl restart networking)"
    echo "5. 返回主菜单"
    read -p "选择功能 [1-5]: " cmdopt

    case $cmdopt in
        1) lsblk ;;
        2) read -p "请输入共享磁盘路径（如/dev/sdb1）: " disk; read -p "请输入挂载目录: " mnt; mkdir -p "$mnt"; mount "$disk" "$mnt" && echo "挂载完成" ;;
        3) ip a ;;
        4) systemctl restart networking && echo "网络已重启" ;;
        5) show_main_menu ;;
        *) echo "无效选项..." ;;
    esac
    read -p "按回车继续..." temp
    common_cmd_menu
}

show_main_menu
