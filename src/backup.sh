#!/bin/sh
[ -z "$dest" ] && echo "Target destination not specified." 1>&2 && exit 255

[ -z "$src" ] && src=/
[ -z "$rotate" ] && rotate=5
[ -z "$stamp" ] && stamp=$(date +%Y%m%d%H%M%S)
[ -z "$ssh" ] && ssh=ssh
[ -z "$rsync" ] && rsync="ionice -c 2 -n 7 nice -n 19 rsync"
[ -z "$params" ] && params=-avzxXAHES

stamp=$(eval echo $stamp)
params=$(eval echo $params)

# If doing local backup, check if we are backing up on different mountpoint.
# Or, in other words, check if user has forgotten to mount their backup destination.
[ -z "$host" ] && [ "$(df -P $(eval echo "$src") | tail -1 | cut -d' ' -f 1)" = "$(df -P "$dest" | tail -1 | cut -d' ' -f 1)" ] && echo "Refusing to backup to same filesystem." 1>&2 && exit 254

if [ -z "$host" ]; then
	stamps=$(ls -1 "$dest" 2> /dev/null)
else
	stamps=$(ssh "$host" "ls -1 '$dest'" 2> /dev/null)
fi

laststamp=$(echo "$stamps" | sort -nr | head -n 1)
firststamp=$(echo "$stamps" | sort -n | head -n 1)

if [ "$rotate" -gt "1" ] && [ "$(echo "$stamps" | wc -l)" -ge "$rotate" ]; then
	if [ -z "$host"]; then
		rm -Rf "$dest/$firststamp"
	else
		ssh "$host" "rm -Rf '$dest/$firststamp'"
	fi
fi

if [ -z "$host" ]; then
	exec rsync $params --link-dest="$dest/$laststamp" $src "$dest/$stamp"
else
	exec rsync --rsync-path="$rsync" -e "$ssh" $params --link-dest="$dest/$laststamp" $src "$host:$dest/$stamp"
fi
