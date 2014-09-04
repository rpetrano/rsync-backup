#!/bin/sh
[ -z "$host" ] && echo "Target hostname not specified." && exit 255
[ -z "$dest" ] && echo "Target destination not specified." && exit 255

[ -z "$src" ] && src=/
[ -z "$rotate" ] && rotate=5
[ -z "$stamp" ] && stamp=$(date +%Y%m%d%H%M%S)
[ -z "$ssh" ] && ssh=ssh
[ -z "$rsync" ] && rsync="ionice -c 2 -n 7 nice -n 19 rsync"
[ -z "$params" ] && params=-avzxXAHES

stamps=$(ssh "$host" "ls -1 '$dest'" 2> /dev/null)
laststamp=$(echo "$stamps" | sort -nr | head -n 1)
firststamp=$(echo "$stamps" | sort -n | head -n 1)

if [ "$rotate" -gt "1" ] && [ "$(echo "$stamps" | wc -l)" -ge "$rotate" ]; then
	ssh "$host" "rm -Rf '$dest/$firststamp'"
fi

exec rsync --rsync-path="$rsync" -e "$ssh" $params --link-dest="$dest/$laststamp" $src "$host:$dest/$stamp"
