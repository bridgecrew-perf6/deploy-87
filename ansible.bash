#!/bin/bash
if [ $(getent passwd ansible) ]; then
  echo "User \"ansible\" already exists." ; exit 1 ; fi

random() {
    test -z "$1" && n="32"|| n="$1"
    tr -cd '[:alnum:]' < /dev/urandom | fold -w"$n" | head -n1 ; }

groupadd ansible && \
useradd ansible \
  --shell "/bin/bash" \
  --groups ansible \
  --system \
  --no-user-group \
  --no-create-home
echo ansible:$(random 64) | chpasswd

if ! test -d /etc/sudoers.d ; then
  mkdir /etc/sudoers.d ; chown root:root /etc/sudoers.d ; chmod 500 /etc/sudoers.d ; fi
cp "$wkd"/files/sudoers.ansible /etc/sudoers.d/ansible \
  && chmod 400 /etc/sudoers.d/*

if ! test -d /etc/ssh/sshd_config.d ; then
  mkdir /etc/ssh/sshd_config.d ; chown root:root /etc/ssh/sshd_config.d ; chmod 700 /etc/ssh/sshd_config.d ; fi
cp "$wkd"/files/sshd_cfg-ansible /etc/ssh/sshd_config.d/lusr-ansible.conf \
  && find /etc/ssh/sshd_config.d -type f -exec chmod 400 {} \;

get_pubkey_local() {
  r=$(find "$wkd"/files -type f -name "ansible@kevtx-*.pub")
  if [ $(echo "$r" | wc -l) -eq 1 ]; then
    test -d /root/.ssh || mkdir /root/.ssh
    cat "$r" > /root/.ssh/authorized_keys.ansible \
      && chmod 400 /root/.ssh/authorized_keys.ansible
  elif [ $(echo "$r" | wc -l) -eq 0 ]; then
    echo "No ansible public key found."
    exit 1
  elif [ $(echo "$r" | wc -l) -gt 1 ]; then
    echo "Multiple ansible public keys found."
    exit 1
  else
    echo "Unexpected error."
    exit 1
  fi
}; get_pubkey_local

systemctl reload ssh.service
