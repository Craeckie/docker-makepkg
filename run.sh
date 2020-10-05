#!/bin/sh
chown notroot -R "$PKGDEST"
echo "Parameters: $@"
exec su -c "exec pikaur --noconfirm -Syuw \"$@\"" notroot
