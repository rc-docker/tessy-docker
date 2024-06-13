#!/bin/bash -e

# logging functions
tessy_log() {
	local type="$1"; shift
	# accept argument string or stdin
	local text="$*"; if [ "$#" -eq 0 ]; then text="$(cat)"; fi
	local dt; dt="$(date --rfc-3339=seconds)"
	printf '%s [%s] [Entrypoint]: %s\n' "$dt" "$type" "$text"
}

tessy_note() {
	tessy_log Note "$@"
}

tessy_warn() {
	tessy_log Warn "$@" >&2
}

tessy_error() {
	tessy_log ERROR "$@" >&2
	exit 1
}

# check to see if this file is being run or sourced from another script
_is_sourced() {
	# https://unix.stackexchange.com/a/215279
	[ "${#FUNCNAME[@]}" -ge 2 ] \
		&& [ "${FUNCNAME[0]}" = '_is_sourced' ] \
		&& [ "${FUNCNAME[1]}" = 'source' ]
}

_main() {
	# If container is started as root user, restart as dedicated tessy user
	if [ "$(id -u)" = "0" ]; then
		# Add local user
		# Either use the LOCAL_USER_ID if passed in at runtime or
		# fallback
		USER_ID=${LOCAL_USER_ID:-9001}

		useradd --shell /bin/bash -u $USER_ID -o -c "" -m tessy
		tessy_note "Switching to dedicated user 'tessy'"

		exec gosu tessy "$BASH_SOURCE" "$@"
	fi

	if [ -z "$DISPLAY" ]; then
		export DISPLAY=":1"
		echo "DISPLAY variable was not defined. Setting it to :1."
	fi

	Xvfb $DISPLAY -screen 0 640x480x8 -nolisten tcp -nolisten unix &
	exec "$@"

	if [ $? -eq 0 ] && [ -n "$EXPORT_LOG" ]; then 
		local CURRENT_LOGFILE="log.$(date -I)"
		tessy_error "Detected error. Copied tessy .log to $CURRENT_LOGFILE"
		cp ~/.razorcat/.tessy/.tessy_50_workspace/.metadata/.log "$CURRENT_LOGFILE"
	fi

}


# If we are sourced from elsewhere, don't perform any further actions
if ! _is_sourced; then
	_main "$@"
fi
