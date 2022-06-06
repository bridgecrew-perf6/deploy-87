# User: Ansible
random() {
    test -z "$1" && n="32"|| n="$1"
    tr -cd '[:alnum:]' < /dev/urandom | fold -w"$n" | head -n1
}
ak="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDSfLUsSEIK8MOgr+CGvAlP0ue2dxSV7L/Lwh2/wVnEpy4itOTrKzmKp1qorpLtHQDNhwIbLt7WAmuyGnrHjMzkOx4F9ixIthzwdFzjxk+gJvCZ6Y6kmIZblKFTzXiMhXf1fDgMje0ipJ92Fy03sx8oA3vffn9oIG78JGYIrcG16UOOvNHRITvA67JWTbws7CeIXvNT+8SKF0FXX8c1bwfJd0OvwnG68WiGRnHlMYpX9/+wdAMRNQwRDrvlq8FTdpe30iIwH7C0XXz08m7fWs706JGQHAMXwEPi62Eh4ecU+JL2jKadb44nQo7rB84FLvSZhu42C7/IEgSX1BgQsrQ0H7BLs9R4RsyIu0SWRXy/1HRHO4kVRzP4Iki064mrApZ0kAlxVpkXza0ND9cPBxyyATmUW2kkm+CEJutZmItfkbgLlEfhWFt02Y0FyyLS2ybASd68cnYyem3Pm9JiByLMfaORpoPttXqWOKTplNWlW6E9xb8/STCM3n9lKO+Mios="
sudoers="ansible ALL=(ALL:ALL) NOPASSWD:ALL\n"
sshd="Match User ansible Address 10.7.7.1/32\n  PubkeyAuthentication yes\n  AuthorizedKeysFile /etc/ansible/.ssh/authorized_keys"
# Create group
    if ! [ $(getent group ansible) ]; then groupadd ansible; fi
# Create user
    if ! [ $(getent passwd ansible) ]; then
        useradd ansible \
            --home "/etc/ansible" \
            --shell "/bin/bash" \
            --groups ansible \
            --system \
            --no-user-group \
            --no-create-home
        echo ansible:$(random 64) | chpasswd ; fi
# User as member of group
    groups ansible | grep -q "\bansible\b" || \
    usermod -aG ansible ansible
# User home directory w/ authorized keys
    test -d /etc/ansible || mkdir -p /etc/ansible/.ssh
    echo -e "$ak" > /etc/ansible/.ssh/authorized_keys
    chown -R ansible:ansible /etc/ansible && \
    find /etc/ansible -type d -exec chmod 700 {} \;
    find /etc/ansible -type f -exec chmod 600 {} \;
# sudoers.d config file
    echo -e "$sudoers" > /etc/sudoers.d/ansible && \
    chown -R root:root /etc/{sudoers,sudoers.d} && \
    chmod 500 /etc/sudoers.d && \
    find /etc/sudoers.d -maxdepth 1 -type f -exec chmod 400 {} \;
# sshd_config.d config file
    echo -e "$sshd" > /etc/ssh/sshd_config.d/ansible.conf
    systemctl reload sshd