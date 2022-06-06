#!/bin/bash
payload="AcceptEnv LANG LC_*\nPrintMotd no\n\nPermitRootLogin no\n\nPubkeyAuthentication no\nPermitEmptyPasswords no\nPasswordAuthentication no\n\nChallengeResponseAuthentication no\nUsePAM no\nX11Forwarding no\n\nInclude /etc/ssh/sshd_config.d/*.conf"

# Move old sshd_config file
if test -f /etc/ssh/sshd_config; then mv /etc/ssh/sshd_config /etc/ssh/.sshd_config.old_"$(date +%F_%Hh-%Mm-%Ss)"; fi

# Create sshd_config.d folder
if ! test -d /etc/ssh/sshd_config.d; then mkdir /etc/ssh/sshd_config.d; fi

# Create new baseline sshd_config
payload() {
  echo -e "$payload" > /etc/ssh/sshd_config && \
  chown root:root /etc/ssh/sshd_config && \
  chmod 644 /etc/ssh/sshd_config
}; payload
