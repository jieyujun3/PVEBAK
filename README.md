# PVEBAK

常用菜单

curl -fsSL https://raw.githubusercontent.com/jieyujun3/PVEBAK/main/pve-toolkit.sh -o pve-toolkit.sh
chmod +x pve-toolkit.sh
./pve-toolkit.sh




备份

bash <(curl -sSL https://raw.githubusercontent.com/jieyujun3/PVEBAK/main/pve_backup_restore.sh) backup

恢复

bash <(curl -sSL https://raw.githubusercontent.com/jieyujun3/PVEBAK/main/pve_backup_restore.sh) restore

备份打包本地VM


tar czf /root/local_vm_backup_$(date +%F).tar.gz /etc/pve/qemu-server /var/lib/vz/images

恢复本地vm：（上传备份文件到根目录或者git）

curl -sSL https://raw.githubusercontent.com/jieyujun3/PVEBAK/main/restore_vm.sh -o restore_vm.sh
chmod +x restore_vm.sh
./restore_vm.sh


一、恢复配置后需要特别注意的地方
1. OSD 和 Ceph 恢复注意点
恢复 /etc 配置后，你需要：

🔧 确保以下几点完整还原：
/etc/ceph/（Ceph 配置文件、密钥等）

/var/lib/ceph/（OSD metadata，本地磁盘信息）

/etc/pve/（PVE 集群配置，特别重要）

/etc/network/interfaces 或 /etc/network/（网络桥接关系）

⚠️ OSD 相关注意事项：
如果是 原系统硬盘未格式化，原 OSD 数据未动，配置一还原就可以自动识别 OSD。

若重装系统后丢失 /var/lib/ceph/，OSD 可能显示 down 或 not found。此时：

需要运行 ceph-volume lvm list 查看磁盘状态；

手动 ceph-volume lvm activate <osd-id> <osd-uuid> 恢复；

或者用 ceph-volume lvm activate --all 尝试全部激活。

2. 集群认证和通信
如果 /etc/pve/ 完全还原，集群节点应该可以自动发现并重新加入。

时间同步必须正确（chronyd 或 systemd-timesyncd），否则会报集群认证失败。

✅ 二、本地虚拟机（VM）备份建议
如果你有在本地存放的虚拟机（非 Ceph 磁盘），建议你额外备份这些路径：

📁 本地 VM 配置：
/etc/pve/qemu-server/：存储每个虚拟机的 .conf 配置文件，非常关键！

/var/lib/vz/images/：本地 VM 的磁盘镜像（如果未存储在 Ceph/RBD 中）

🧩 你可以这样打包：
bash




tar czf /root/local_vm_backup_$(date +%F).tar.gz /etc/pve/qemu-server /var/lib/vz/images




✅ 三、恢复步骤建议
恢复前请确认以下顺序：

步骤	动作
1	安装基础 PVE 系统
2	安装 Ceph 并匹配版本（如 18.2.7）
3	下载执行恢复脚本 restore
4	重启系统检查服务状态
5	使用 ceph-volume lvm list 检查 OSD
6	恢复本地虚拟机配置和磁盘（如有）




📦 进阶建议
脚本中加入 /var/lib/ceph 备份选项（默认不动数据盘）

如果你 Ceph 用的是 SSD+HDD 混合模式，还可以备份 lvs 和 bluestore 映射表以便日后排错
