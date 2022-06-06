#!/bin/bash
for i in $(find . -type f -name "*-*.bash" | sort); do
  chmod a+x "$i" && \
  /bin/bash -c "$i"
done
