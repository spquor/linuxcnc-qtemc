#!/bin/bash

KILL_TIMEOUT=100

killall qtemc

while [ $KILL_TIMEOUT -gt 1 ]; do
		if ! [ -f /tmp/linuxcnc.lock ]; then
				echo "OK"
				break
		else
				KILL_TIMEOUT=$((KILL_TIMEOUT-1))
				sleep .1
		fi
done
