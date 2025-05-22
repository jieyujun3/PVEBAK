#!/bin/bash

# === 用户自定义部分 ===
BACKUP_URL="https://yourdomain.com/backups/pve3_etc_backup_latest.tar.gz"  # 你上传备份包的地址
TMP_DIR="/tmp/pve_restore"
ARCHIVE_NAME="pve_restore.tar.gz"

echo "[*] 开始 PVE 配置恢复流程..."

# === 下载备份 ===
mkdir -p "${TMP_DIR}"
cd "${TMP_DIR}"

echo "[*] 下载配置备份..."
curl -L -o "${ARCHIVE_NAME}" "${BACKUP_URL}"

if [ $? -ne 0 ]; then
    echo "[!] 下载失败，退出恢复"
    exit 1
fi

# === 解压恢复配置 ===
echo "[*] 解压配置..."
tar -xzvf "${ARCHIVE_NAME}" -C /

# === 修复权限（特别是 /etc/pve）===
chown -R root:root /etc/pve
chmod 755 /etc/pve

# === 重启核心服务 ===
echo "[*] 重启网络和PVE服务..."
systemctl restart networking
systemctl restart pve-cluster
systemctl restart corosync
systemctl restart ceph.target

echo "[*] 恢复完成，建议执行以下命令检查："
echo "   pvecm status"
echo "   ceph -s"

# === 清理临时文件（可选）===
# rm -rf "${TMP_DIR}"
