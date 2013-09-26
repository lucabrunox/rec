#!/bin/bash

function usage() {
    echo "Usage: $0 [OPTIONS] FILE"
    echo "rec version 1.0."
    echo "Opens a file on your local emacs frame from within a remote shell."
    echo
    echo "Common options:"
    echo -e "-h\t\t\tPrint usage and return"
    echo -e "-v\t\t\tTurn on verbose mode"
    echo -e "-i\t\t\tUse the given configuration to install on the remote server"
    echo -e "-m MODE\t\t\tMode is one of public, reverse, forward (default: public)"
    echo -e "-t MODE\t\t\tTramp mode (default: sshx)"
    echo -e '-r HOST[:PORT]\t\tRemote ssh server (default: inferred from $SSH_CONNECTION)'
    echo
    echo "PUBLIC MODE"
    echo "Connects to a local ssh server. The local ssh server has to be accessible from"
    echo "the remote server."
    echo "Options:"
    echo -e '-l HOST[:PORT]\t\tLocal ssh server (default: inferred from $SSH_CONNECTION)'
    echo
    echo "REVERSE MODE"
    echo "Uses a remote forwarded port to the local ssh server, useful if you are behind NAT."
    echo "This requires the ssh connection to have a forwarded port."
    echo "Options:"
    echo -e "-p PORT[:HOSTPORT]\tRemote forwarded port of the local ssh server."
    echo
    echo "FORWARD MODE"
    echo "Uses a remote forwarded port directly to the emacs server."
    echo "Requires the server to have emacsclient, and the local emacs server to listen on a TCP socket."
    echo "Options:"
    echo -e "-p PORT[:HOSTPORT]\tRemote forwarded port of the local emacs server."
}

VERBOSE=1
LOCAL=${SSH_CONNECTION% * *}
LOCALADDR=${LOCAL% *}
LOCALPORT=22
REMOTE=${SSH_CONNECTION#* * }
REMOTEADDR=${REMOTE% *}
REMOTEPORT=${REMOTE#* }
MODE=public
TRAMP=sshx

if [ ! -f "$HOME/.rec.conf" ]; then
    echo "warning: configuration not found: $HOME/.rec.conf" >&2
else
    . $HOME/.rec.conf
fi

while getopts "hvVil:r:m:p:" opt; do
    case $opt in
	h)
	    usage
	    exit 0
	    ;;
	v)
	    VERBOSE=1
	    ;;
	l)
	    LOCALADDR=${OPTARG%:*}
	    LOCALPORT=${OPTARG#*:}
	    ;;
	r)
	    REMOTEADDR=${OPTARG%:*}
	    REMOTEPORT=${OPTARG#*:}
	    ;;
	m)
	    MODE=$OPTARG
	    ;;
	p)
	    LOCALPORT=${OPTARG%:*}
	    HOSTPORT=${OPTARG#*:}
	    ;;
	i)
	    echo "error: install not yet supported"
	    exit 1
	    ;;
	\?)
	    exit 1
	    ;;
    esac
done

if [ ! "$REMOTEADDR" ]; then
    echo "error: remote address required" >&2
    exit 1
fi
if [ ! "$REMOTEPORT" ]; then
    echo "error: remote port required" >&2
    exit 1
fi

case $MODE in
    public)
	if [ ! "$LOCALADDR" ]; then
	    echo "error: local address required for public mode" >&2
	    exit 1
	fi
	if [ ! "$LOCALPORT" ]; then
	    echo "error: local port required for public mode" >&2
	    exit 1
	fi
	;;
    reverse)
	echo "error: reverse mode not yet supported"
	exit 1

	if [ ! "$LOCALPORT" ]; then
	    echo "error: local port required for reverse mode" >&2
	    exit 1
	fi
	if [ ! "$HOSTPORT" ]; then
	    
	    HOSTPORT=22
	fi
	;;
    forward)
	echo "error: forward mode not yet supported"
	exit 1

	if [ ! "$LOCALPORT" ]; then
	    echo "error: local port required for forward mode" >&2
	    exit 1
	fi
	if [ ! "$HOSTPORT" ]; then
	    HOSTPORT=$LOCALPORT
	fi
	;;
    *)
	echo "error: invalid mode: $MODE" >&2
	exit 1
esac
shift $(($OPTIND - 1))

FILE="$(readlink -f "$1")"
if [ "$VERBOSE" = "1" ]; then
	echo ssh -t -p $LOCALPORT $LOCALUSER@$LOCALADDR emacsclient -d :0 -n "/sshx:$(whoami)@$REMOTEADDR#$REMOTEPORT:$FILE"
fi

ssh -t -p $LOCALPORT $LOCALUSER@$LOCALADDR emacsclient -d :0 -n "/sshx:$(whoami)@$REMOTEADDR#$REMOTEPORT:$FILE"
