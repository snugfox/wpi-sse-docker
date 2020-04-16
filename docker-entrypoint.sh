#!/bin/sh

set -eu
no_aslr=0

for opt in $(echo ${OPTS:-} | tr ";," " "); do
    case "$opt" in
        corefile)
            ulimit -c unlimited
            ;;
        no_aslr)
            no_aslr=1
            ;;
        no_pwndbg)
            sed -i '/^source\s\+\/opt\/pwndbg\/gdbinit\.py/d' /root/.gdbinit
            ;;
        *)
            echo "error: unrecognized option $opt" 1>&2
            exit 1
            ;;
    esac
done
unset OPTS

if [ $no_aslr -ne 0 ]; then
    exec setarch $(arch) -R "$@"
fi
exec "$@"
