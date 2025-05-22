#!/bin/bash
# PVE+Ceph 一键备份和恢复脚本
# GitHub: https://github.com/jieyujun3/PVEBAK

set -e

BACKUP_DIR="/root/pve_backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="backup_$TIMESTAMP.tar.gz"

function backup_config() {
    echo "[+] 备份文件到 $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"

    cp -a /etc/pve "$BACKUP_DIR/" 2>/dev/null || echo "[!] 转成pve文件失败 (maybe not mounted)"
    cp -a /etc/ceph "$BACKUP_DIR/"
    cp -a /etc/network/interfaces "$BACKUP_DIR/"
    cp -a /etc/hosts "$BACKUP_DIR/"
    cp -a /etc/fstab "$BACKUP_DIR/"

    tar -czf "/root/$BACKUP_NAME" -C /root pve_backup
    echo "[+] 备份成功：/root/$BACKUP_NAME"
}

function restore_config() {
    echo "[+] 恢复配置文件"
    read -p "请输入要恢复的 tar.gz 备份文件路径：" TARBALL

    if [ ! -f "$TARBALL" ]; then
        echo "[!] 文件不存在"
        exit 1
    fi

    tar -xzf "$TARBALL" -C /root
    cp -a /root/pve_backup/pve/* /etc/pve/ || echo "[!] 无pve/文件或空"
    cp -a /root/pve_backup/ceph/* /etc/ceph/
    cp -a /root/pve_backup/interfaces /etc/network/interfaces
    cp -a /root/pve_backup/hosts /etc/hosts
    cp -a /root/pve_backup/fstab /etc/fstab

    echo "[+] 恢复完成，请重启系统"
}

function usage() {
    echo "Usage: $0 [backup|restore]"
}

case "$1" in
    backup)
        backup_config
        ;;
    restore)
        restore_config
        ;;
    *)
        usage
        ;;
esac
