#!/bin/bash
. $HOME/.rec.conf

if [ "$1" = "-v" ]; then
	FILE="$(readlink -f "$2")"
	echo ssh -t -p $LOCALPORT $LOCALUSER@$LOCALADDR emacsclient -d :0 -n "/sshx:$(whoami)@$REMOTEADDR#$REMOTEPORT:$FILE"
else
	FILE="$(readlink -f "$1")"
fi

ssh -t -p $LOCALPORT $LOCALUSER@$LOCALADDR emacsclient -d :0 -n "/sshx:$(whoami)@$REMOTEADDR#$REMOTEPORT:$FILE"
