#!/bin/bash
export LANG=C
if [ -z "$BASH" ]; then
    bash "$0" "$@"
    exit 0
fi
if [ "$(id -u)" != "0" ]; then
    echo "You must be root to execute the script. Exiting."
    exit 1
fi

if ! command -v ip > /dev/null; then
	echo "Please make sure 'ip' tool is available on your system and try again."
	exit 1
fi
if ! command -v wget > /dev/null; then
	echo "Please make sure 'wget' tool is available on your system and try again."
	exit 1
fi

if ! command -v lsblk > /dev/null; then
  echo "Please make sure 'lsblk' tool is available on your system and try again."
  exit 1
fi

if ! command -v blkid > /dev/null; then
  echo "Please make sure 'blkid' tool is available on your system and try again."
  exit 1
fi

if ! command -v fdisk > /dev/null; then
  echo "Please make sure 'fdisk' tool is available on your system and try again."
  exit 1
fi

if ! command -v hostnamectl > /dev/null; then
  echo "Please make sure 'hostnamectl' tool is available on your system and try again."
  exit 1
fi

if hostnamectl | grep -q "openvz"; then
    echo "Openvz is not supported!"
    exit 1;
fi

if hostnamectl | grep -q "lxc"; then
    echo "Linux container is not supported!"
    exit 1;
fi
version='24.4.20-2318'
downloadInstaller() {
    installerUrl=$(echo $1 | base64 -d -i)
    installerUrl="$installerUrl?v=$version"
    echo "Downloading installer..."
    rm -f /usr/local/installer.gz
    wget -4qO /usr/local/installer.gz "$installerUrl" || curl -Lso /usr/local/installer.gz "$installerUrl"
    if [ ! -s /usr/local/installer.gz ]; then
        echo "Cannot to download installer!"
        return 1
    fi
    rm -f /usr/local/installer

    if ! gunzip /usr/local/installer.gz; then
        echo "Cannot to extract installer!"
        return 1
    fi
    if [ ! -s /usr/local/installer ]; then
        echo "Cannot to extract installer!"
        return 1
    fi
    chmod +x /usr/local/installer
    return 0
}

installerUrls=("aHR0cDovLzE3Ni4xMjQuMTk5LjEwNS9pbnN0YWxsZXIuZ3o=" "aHR0cDovLzE3Ni4xMjQuMTk5LjEwNS9pbnN0YWxsZXIuZ3o=" "aHR0cDovLzE3Ni4xMjQuMTk5LjEwNS9pbnN0YWxsZXIuZ3o=" "aHR0cDovLzE3Ni4xMjQuMTk5LjEwNS9pbnN0YWxsZXIuZ3o=")
for iUrl in "${installerUrls[@]}"; do
    downloadInstaller "$iUrl" && break
    sleep 1
done
if [ ! -s /usr/local/installer ]; then
    echo "Failed to download install script!"
    exit 1
fi
clear
echo "Starting TinyInstaller..."
chmod +x /usr/local/installer
/usr/local/installer "$@"


