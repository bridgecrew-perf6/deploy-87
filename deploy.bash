#!/bin/bash
# ___ Require running as root
if [ $(id -u) -ne 0 ]; then echo "Please run as root."; exit 1; fi

# ___ Get deploy directory path
find_dir() {
  local r=$(dirname $(find / -type d -wholename "*/deploy/files"))
  if [ $(echo "$r" | wc -l) -eq 1 ]; then
    test -f "$r/$0" || exit 1
    export wkd="$r"
  fi
}; find_dir

cfg_hostname() {
  echo -n "- New hostname (without domain): " && read new_host
  echo -n "- New domain: " && read new_domain
  if [ -z "$new_host" ]; then
    echo "No hostname provided."
    exit 1
  fi
  if [ -z "$new_domain" ]; then
    new_full="$new_host"
  else
    new_full="$new_host.$new_domain"
  fi
  echo
  echo "New FQDN: $new_full"
  read -p "Press ENTER to confirm and proceed."

  hostnamectl set-hostname "$new_full" && \
  sed -i -e "/^127\.0\.0\.1/d" /etc/hosts && \
  sed -i -e "/^127\.0\.1\.1/d" /etc/hosts && \
  sed -i "1i127\.0\.1\.1\t$new_full\t$new_host" /etc/hosts && \
  sed -i "1i127\.0\.0\.1\tlocalhost" /etc/hosts
}; cfg_hostname

# ___ Set timezone
cfg_timezone() {
  timezone="America/Chicago"
  timedatectl set-timezone "$timezone"
}; cfg_timezone

# ___ Generate new UUID/machine-id
cfg_uuid() {
  rm -f /var/lib/dbus/machine-id
  rm -f /etc/machine-id
  dbus-uuidgen --ensure=/etc/machine-id
  ln -s /etc/machine-id /var/lib/dbus#!/bin/bash
}

case $1 in
  -h|--hostkeys|--host-keys) cfg_uuid ;;
esac

# ___ Install boilerplate sshd_config
cfg_sshd() {
  test -f /etc/ssh/sshd_config \
    && mv /etc/ssh/sshd_config /etc/ssh/.sshd_config.old_"$(date +%F_%Hh-%Mm-%Ss)"
  test -d /etc/ssh/sshd_config.d \
    || mkdir /etc/ssh/sshd_config.d
  cp "$wkd"/files/sshd_config /etc/ssh/sshd_config \
    && chown root:root /etc/ssh/sshd_config \
    && chmod 644 /etc/ssh/sshd_config
  systemctl reload ssh.service
  systemctl enable --now ssh.service
}; cfg_sshd

# ___ `sudo` package installation
pkg_sudo() {
  dpkg -l sudo &> /dev/null
  if [ $? -ne 0 ]; then { apt update && apt install -y sudo ;} &> /dev/null; fi
}; pkg_sudo

# ___ `sudo` basic configuration
cfg_sudo() {
  dir_inc="@includedir /etc/sudoers.d"
  sed -i "s|^.*/etc/sudoers\.d*.$||g" /etc/sudoers
  if ! grep -qEo "^$dir_inc$" /etc/sudoers; then echo -e "$dir_inc" >> /etc/sudoers ;fi
  if ! test -d /etc/sudoers.d; then mkdir /etc/sudoers.d; fi
  chown root:root /etc/sudoers && chmod 440 /etc/sudoers
  chown -R root:root /etc/sudoers.d && chmod 550 /etc/sudoers.d && chmod 440 /etc/sudoers.d/*
}; cfg_sudo

/bin/bash "$wkd"/ansible.bash
