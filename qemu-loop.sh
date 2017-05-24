#!/bin/bash

TIMEOUTSECONDS=20

function run {
    LOGDATE=$(date +%Y%m%d-%H%M%S)
    LOG=$LOGDATE.log
    PROGRAMSTARTED=0
    date > $LOG
    coproc qemu-system-arm \
        -M versatilepb -cpu cortex-a8 \
        -m 64M -serial mon:stdio \
        -usb -net none -display none \
        -kernel artifacts/QEMUVPB/kernel.bin \
        -append "LOGGING_INCLUDE_TICKCOUNT=1" \
        2> qemu.stderr

    while [[ 1 == 1 ]]
    do
        read -t $TIMEOUTSECONDS LINE <&${COPROC[0]}
        if [[ $? == 0 ]]
        then
            echo "$LINE" >> $LOG
            if [[ $LINE == *"program"* ]]
            then
#               echo $LOG $LINE
                PROGRAMSTARTED=1
                if [[ $LINE == *"program stop"* ]]
                then
                    stopqemu
                    break
                fi
            fi
        else
            stopqemu
            echo >> $LOG
            if [[ $PROGRAMSTARTED == 1 ]]
            then
                echo test failed - log monitor did not receive any more log messages >> $LOG
            else
                echo test failed - program never reached start point >> $LOG
            fi
            break
        fi
    done
    dos2unix -q $LOG
#   egrep '(test succeeded|error|fail)' $LOG
    egrep '(error|fail)' $LOG
    if [[ $? != 0 ]]
    then
        echo succeeded
        mv $LOG ok-$LOG
    else
        mv $LOG fail-$LOG
    fi
}

function stopqemu {
    echo -en '\001c' >&${COPROC[1]}
    echo "screendump screen-$LOGDATE.pnm" >&${COPROC[1]}
    sleep 1
    convert screen-$LOGDATE.pnm screen-$LOGDATE.png
    convert screen-$LOGDATE.pnm -crop 1024x100+0+0 top-$LOGDATE.pnm
    diff top-$LOGDATE.pnm top-success.pnm.save
    if [[ $? != 0 ]]
    then
        echo test failed - screen capture was not green >> $LOG
    fi
    rm screen-$LOGDATE.pnm top-$LOGDATE.pnm
    kill -9 $COPROC_PID
    wait $COPROC_PID 2> /dev/null
}

while [[ 1 == 1 ]]
do
    run
    if [[ $PROGRAMSTARTED == 0 ]]
    then
        break
    fi
done
