# **RHCSA (Red Hat Certified System Administrator) - Zero to Hero Course Plan**

This structured course will take you from **zero knowledge** to **RHCSA-certified hero** by covering all exam objectives (based on **RHEL 9**) with hands-on labs, real-world scenarios, and exam-focused practice.

---

## **📌 Course Overview**
- **Exam Code**: **EX200** (RHEL 9)
- **Prerequisites**: Basic Linux familiarity (helpful but not required)
- **Duration**: 6-8 weeks (depending on prior experience)
- **Exam Format**: **3-hour hands-on lab**, performance-based tasks

---

## **📚 Course Breakdown**
### **Week 1: Linux Fundamentals & Command Line Basics**
**Objective**: Master essential Linux commands and filesystem navigation.
- **Topics**:
  - Linux filesystem hierarchy (`/`, `/home`, `/etc`, `/var`, `/usr`)
  - Basic commands (`ls`, `cd`, `pwd`, `cat`, `echo`, `touch`, `mkdir`, `rm`)
  - File permissions (`chmod`, `chown`, `chgrp`, `umask`)
  - Text manipulation (`grep`, `awk`, `sed`, `cut`, `sort`, `uniq`)
  - Redirection & pipes (`>`, `>>`, `|`, `2>`, `&>`)
- **Lab**:
  - Create, delete, and modify files/directories.
  - Use `grep` and `awk` to filter logs.
  - Change permissions and ownership.

---

### **Week 2: User & Group Management**
**Objective**: Control access and manage users/groups.
- **Topics**:
  - User management (`useradd`, `usermod`, `userdel`, `passwd`)
  - Group management (`groupadd`, `groupmod`, `groupdel`)
  - Password aging (`chage`)
  - Sudo privileges (`visudo`, `/etc/sudoers`)
- **Lab**:
  - Create users with specific UIDs/GIDs.
  - Configure sudo access for a group.
  - Set password expiration policies.

---

### **Week 3: Filesystem & Storage Management**
**Objective**: Manage disks, partitions, and filesystems.
- **Topics**:
  - Disk partitioning (`fdisk`, `gdisk`, `parted`)
  - Filesystem creation (`mkfs.xfs`, `mkfs.ext4`)
  - Mounting (`mount`, `umount`, `/etc/fstab`)
  - Persistent mounts with UUID/Labels
  - Swap management (`mkswap`, `swapon`, `swapoff`)
  - LVM (Logical Volume Manager):
    - PV (Physical Volume), VG (Volume Group), LV (Logical Volume)
    - Extending VG/LV (`vgextend`, `lvextend`, `xfs_growfs`, `resize2fs`)
- **Lab**:
  - Add a new disk, partition, format, and mount.
  - Extend an LV and resize the filesystem.
  - Configure swap space.

---

### **Week 4: Networking & SSH**
**Objective**: Configure networking and remote access.
- **Topics**:
  - Network interfaces (`nmcli`, `ip`, `ifconfig`)
  - Static vs. DHCP configuration
  - Hostname management (`hostnamectl`)
  - SSH (`ssh`, `scp`, `ssh-keygen`, `~/.ssh/config`)
  - Firewall (`firewalld`, `firewall-cmd`, zones, services)
- **Lab**:
  - Set a static IP using `nmcli`.
  - Restrict SSH access to specific users.
  - Allow HTTP traffic through `firewalld`.

---

### **Week 5: Package Management & System Services**
**Objective**: Install software and manage services.
- **Topics**:
  - RPM (`rpm -ivh`, `rpm -e`, `rpm -qa`)
  - DNF/YUM (`dnf install`, `dnf remove`, `dnf update`)
  - Repositories (`/etc/yum.repos.d/`)
  - System services (`systemctl start|stop|enable|disable|status`)
  - System logging (`journalctl`, `/var/log/messages`)
- **Lab**:
  - Install Apache (`httpd`) and start the service.
  - Configure a custom repo.
  - Filter logs using `journalctl`.

---

### **Week 6: Process Management & Scheduling**
**Objective**: Control processes and automate tasks.
- **Topics**:
  - Process monitoring (`ps`, `top`, `htop`, `pgrep`, `pkill`)
  - Background jobs (`&`, `jobs`, `fg`, `bg`, `nohup`)
  - Cron & at (`crontab -e`, `/etc/cron.d/`, `at`)
- **Lab**:
  - Kill a runaway process.
  - Schedule a backup script with `cron`.

---

### **Week 7: SELinux & Troubleshooting**
**Objective**: Secure systems and diagnose issues.
- **Topics**:
  - SELinux modes (`enforcing`, `permissive`, `disabled`)
  - Contexts (`ls -Z`, `chcon`, `restorecon`, `semanage`)
  - Troubleshooting boot issues (`grub2`, `rescue mode`, `dmesg`)
- **Lab**:
  - Fix an Apache SELinux denial.
  - Recover a broken system using rescue mode.

---

### **Week 8: Final Review & Mock Exams**
**Objective**: Simulate real exam conditions.
- **Mock Exams**:
  - 3 full-length RHCSA practice exams (timed, 3 hours each).
  - Review weak areas.
- **Exam Tips**:
  - Time management.
  - Verifying commands worked (`echo $?`).
  - Using `man` and `--help` effectively.

---

## **🚀 Exam Day Checklist**
✔ Know how to reset root password.  
✔ Practice LVM resizing under time pressure.  
✔ Be comfortable with `nmcli` and `firewall-cmd`.  
✔ Verify all tasks before submitting.  

---

## **🎯 Additional Resources**
- **Books**:  
  - *RHCSA/RHCE Red Hat Linux Certification Study Guide* by Michael Jang.  
- **Practice Labs**:  
  - [Red Hat Developer Subscription (Free)](https://developers.redhat.com)  
  - [KodeKloud RHCSA Labs](https://kodekloud.com)  
- **Official Docs**:  
  - [Red Hat System Administration Guide](https://access.redhat.com/documentation/)  

---

## **💡 Final Advice**
- **Hands-on practice is key**—spend 70% of your time in a lab environment.
- **Use a real RHEL 9 VM** (avoid CentOS Stream for exam prep).
- **Join forums** (Red Hat Community, r/redhat on Reddit).

---

**🔥 You're now ready to ACE the RHCSA!** 🚀  

Would you like a **detailed day-by-day study plan** or **specific lab exercises**? Let me know how I can refine this further!
