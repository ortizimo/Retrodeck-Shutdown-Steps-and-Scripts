#!/bin/sh
# author: ortizimo
# date: 2025.10.15

set -euo pipefail

#===== declared variables =====
PROCESS_PATTERN="${PROCESS_PATTERN:-es-de}"
CHECK_INTERVAL="${CHECK_INTERVAL:-3}"
WAIT_BEFORE_SHUTDOWN="${WAIT_BEFORE_SHUTDOWN:-2}"
SHUTDOWN_CMD="${SHUTDOWN_CMD:-sudo systemctl poweroff}"
#==============================

log() { printf '%s %s\n' "$(date '+%F %T')" "$*"; }

detect_process() {
	pgrep -f "${PROCESS_PATTERN}" >/dev/null 2>&1
}

# monitor program
while true; do
	detect_process && break
	sleep 2
done

# program started - waiting for exit
while true; do
	! detect_process && break
	sleep "${CHECK_INTERVAL}"
done

log "Program exited! Shutdown in ${WAIT_BEFORE_SHUTDOWN} seconds. Ctrl+C to cancel."
trap 'log "Shutdown cancelled by user."; exit 0' INT

for (( i=WAIT_BEFORE_SHUTDOWN; i>0; i-- )); do
	printf '\rShutting down in %ds... (Ctrl+C to cancel)' "$i"
	sleep 1
done
printf '\n'

# executing shutdown
eval "${SHUTDOWN_CMD}"
