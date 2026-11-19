#!/bin/bash

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
	echo "Run this script as root." >&2
	exit 1
fi

FLAG=/var/lib/shielden/user-created
if [[ -f "$FLAG" ]]; then echo "Login already created."; exit 0; fi

while true; do
	read -r -p "New username: " username
	if [[ "$username" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
		break
	fi
	echo "Enter a valid username (lowercase letters, digits, _ or -; start with a letter or _)."
done

while true; do
	read -r -s -p "New password: " password
	echo
	read -r -s -p "Confirm password: " password_confirm
	echo
	if [[ -n "$password" && "$password" == "$password_confirm" ]]; then
		break
	fi
	echo "Passwords must be non-empty and match. Try again."
done

useradd -s /bin/bash -m -d "/home/$username" "$username"
printf '%s:%s\n' "$username" "$password" | chpasswd
unset password password_confirm
echo "User '$username' created."

usermod -aG adm "$username"                                   # can read Snort/system logs
dcv create-session --type virtual --owner "$username" "${username}-session"
mkdir -p /var/lib/shielden && touch "$FLAG"
echo "Done. Sign in to DCV as '$username'."


