#!/bin/bash
for i in $(find . -type f -name "*-*.bash" | sort); do
  /bin/bash -c "$i"
done
