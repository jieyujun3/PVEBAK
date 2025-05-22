#!/bin/bash

# 设置备份路径
BACKUP_DIR="/backup/pve_config_backup"
DATE=$(date +%F_%H-%M-%S)
HOSTNAME=$(hostname)
ARCHIVE_NAME="${HOSTNAME}_etc_backup_${DATE}.tar.gz"

# 创建备份目录
mkdir -p "${BACKUP_DIR}"

# 打包关键配置目录
tar -czvf "${BACKUP_DIR}/${ARCHIVE_NAME}" \
  /etc/pve \
  /etc/network/interfaces \
  /etc/hosts \
  /etc/resolv.conf \
  /etc/hostname \
  /etc/fstab \
  /etc/ceph

# 删除超过30天的旧备份（可选）
find "${BACKUP_DIR}" -type f -name "*.tar.gz" -mtime +30 -exec rm {} \;

echo "备份完成：${ARCHIVE_NAME}"
