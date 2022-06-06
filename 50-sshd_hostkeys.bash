#!/bin/bash
# Set location of hostkeys
hk_dir=/etc/ssh

# Verify folder exists, exit if not
if ! test -d "$hk_dir"; then
  echo "ERROR: hostkey directory does not exist (\$hk_dir: \"$hk_dir\"). [$LINENO]"
  exit 1
fi

#Loop through all hostkey encryption types
hk_types=( rsa dsa ecdsa ed25519 )
for i in "${hk_types[@]}"; do
  hk_type="$i"
  hk_f="$hk_dir"/ssh_host_"$i"_key
  find "$hk_dir" -type f -name ssh_host_"$i"_key* -delete
  if [[ $hk_type == "ecdsa" ]]
    then ssh-keygen -q -f "$hk_f" -N '' -t "$hk_type" -b 521
    else ssh-keygen -q -f "$hk_f" -N '' -t "$hk_type" ; fi
  sed -i "1s|^|HostKey $hk_f\n|" /etc/ssh/sshd_config
done
systemctl reload sshd
if ! systemctl is-active --quiet sshd ; then
    systemctl start sshd; fi