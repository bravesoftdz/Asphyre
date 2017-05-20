#!/bin/bash

# args - kernel, count
# sha256 qemu kernel script
# attach stderr
# ultibo version, board

TIMEOUTSECONDS=7

function run {
    LOG=$(date +%Y%m%d-%H%M%S).log
    date > $LOG
    coproc qemu-system-arm \
        -M versatilepb -cpu cortex-a8 \
        -m 64M -serial stdio -usb -display none \
        -kernel artifacts/QEMUVPB/kernel.bin \
        2> qemu.stderr

    while [[ 1 == 1 ]]
    do
        read -t $TIMEOUTSECONDS LINE <&${COPROC[0]}
        if [[ $? == 0 ]]
        then
            echo "$LINE" >> $LOG
            if [[ $LINE == *"program"* ]]
            then
                echo $(date +%Y%m%d-%H%M%S) $LINE
                if [[ $LINE == *"program stop"* ]]
                then
                    stopqemu
                    break
                fi
            fi
        else
            stopqemu
            echo
            echo failure
            echo
            break
        fi
    done
}

function stopqemu {
    kill -9 $COPROC_PID
    wait $COPROC_PID 2> /dev/null
}

while [[ 1 == 1 ]]
do
    run
done
