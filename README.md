### This is a config file based arch installer

#### Features:
- `wifi-menu` setup
- Disk formatting and GPT/UEFI partitioning
```
+---------------------+
| DISK = /dev/sdX     |
+----------+----------+
| ${DISK}1 | ${DISK}2 |
+----------+----------+
| 260MiB   | 100%     |
|          |          |
| /boot    | /        |
|          |          |
| fs: fat  | fs: ext4 |
+----------+----------+
```
- LUKS encryption on /
- Location based `reflector` mirror setup
- Arch system installation
- Time zone and localisation setup
- Root and user configuration
- `grub` installation on /boot
- Swapfile setup with `systemd-swap`
- Disables system beep
- AUR helper installation
	- Package installation
- Enables systemd services
- Automated home directory setup interface

#### Installation:
**Do not mount something on /mnt instead use for example /usb.**
1. Change the variables in `config.sh`
	- Your list of packages is specified by `PROG`
2. Run: `bash base.sh`

#### Home directory setup:
- `CONFIG_FILES` specifies an URL to your home Git repository
- `INSTALLATION` is the path to your bash setup script, which can symlink for example your pacman config, install a shell and prepare your home environment

#### Credit to:

https://github.com/LukeSmithxyz/LARBS \
https://github.com/helmuthdu/aui \
https://gist.github.com/mattiaslundberg/8620837 \
https://github.com/tom5760/arch-install/blob/master/arch_install.sh \
https://wiki.archlinux.org/

for helping me with some useful code examples...

**If you have questions and/or a problem please consider writing a bug report or message me.**