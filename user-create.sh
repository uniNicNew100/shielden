#!/bin/bash

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
	echo "Run this script as root." >&2
	exit 1
fi

	FLAG=/var/lib/shielden/user-created
	if [[ -f "$FLAG" ]]; then
	username=$(cat "$FLAG")
	if [[ -z "$username" ]]; then
		read -r -p "Enter your existing Shielden username: " username
		if ! id "$username" &>/dev/null; then
			echo "No user called '$username' exists on this instance." >&2
			exit 1
		fi
		echo "$username" > "$FLAG"
	fi
	echo "User '$username' already exists."
	if ! dcv describe-session "${username}-session" &>/dev/null; then
		dcv create-session --type virtual --owner "$username" "${username}-session"
	fi
	echo "Done. Sign in to DCV as '$username'."
	exit 0
	fi

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
	usermod -aG adm,sudo "$username"                                 # Gave sudo privileges to the user so that they can run commands as root
	dcv close-session "${username}-session" 2>/dev/null || true #closes any existing session for the user, if it exists
	dcv create-session --type virtual --owner "$username" "${username}-session"
	mkdir -p /var/lib/shielden && echo "$username" > "$FLAG" #adds created user to the flag so that the script wont prompt new user creation if booted using -Config again
	echo "Done. Sign in to DCV as '$username'."


