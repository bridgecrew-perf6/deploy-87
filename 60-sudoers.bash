#!/bin/bash

# Install package "sudo"
dpkg -l sudo &> /dev/null
if [ $? -ne 0 ]; then { apt update && apt install -y sudo ;} &> /dev/null; fi

# Sudoers basic configuration
payload="@includedir /etc/sudoers.d"

sed -i "s|^.*/etc/sudoers\.d*.$||g" /etc/sudoers
if ! grep -qEo "^$payload$" /etc/sudoers; then echo -e "$payload" >> /etc/sudoers ;fi
if ! test -d /etc/sudoers.d; then mkdir /etc/sudoers.d ;fi

chown root:root /etc/sudoers && \
  chmod 440 /etc/sudoers
chown -R root:root /etc/sudoers.d && \
  chmod 550 /etc/sudoers.d && \
  chmod 440 /etc/sudoers.d/*