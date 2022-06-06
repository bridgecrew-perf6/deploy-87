#!/bin/bash
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