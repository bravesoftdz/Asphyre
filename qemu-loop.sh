#!/bin/bash

TIMEOUTSECONDS=10

function run {
    LOGDATE=$(date +%Y%m%d-%H%M%S)
    LOG=$LOGDATE.log
    PROGRAMSTARTED=0
    date > $LOG
    coproc qemu-system-arm \
        -M versatilepb -cpu cortex-a8 \
        -m 64M \
        -serial file:$LOGDATE.serial \
        -monitor stdio \
        -usb -net none -display none \
        -kernel artifacts/QEMUVPB/kernel.bin \
        -append "LOGGING_INCLUDE_TICKCOUNT=1" \
        2> qemu.stderr

    sleep $TIMEOUTSECONDS
    stopqemu

    cat $LOGDATE.serial >> $LOG

    echo >> $LOG
    PROGRAMSTARTED=$(findLog 'program start')
    if [[ $PROGRAMSTARTED ]]
    then
        echo test failed - program never logged start point >> $LOG
    fi
    if [[ $(findLog 'program stop') ]]
    then
        echo test failed - program never logged stop point >> $LOG
    fi

    dos2unix -q $LOG
    egrep '(error|fail)' $LOG
    FAILED=$?
    if [[ $FAILED == 0 ]]
    then
        mv $LOG fail-$LOG
        mv screen-$LOGDATE.png fail-$LOGDATE.png
    else
        mv $LOG ok-$LOG
        ls -1 ok-* | wc
    fi
}

function findLog {
    grep "$1" $LOGDATE.serial >> /dev/null
    return $?
}

function stopqemu {
    echo "screendump screen-$LOGDATE.pnm" >&${COPROC[1]}
    echo "quit" >&${COPROC[1]}
    wait $COPROC_PID 2> /dev/null
    convert screen-$LOGDATE.pnm screen-$LOGDATE.png
    convert screen-$LOGDATE.pnm -crop 1024x100+0+0 top-$LOGDATE.pnm
    diff top-$LOGDATE.pnm top-success.pnm.save
    if [[ $? != 0 ]]
    then
        echo test failed - screen capture was not green >> $LOG
    fi
    rm screen-$LOGDATE.pnm top-$LOGDATE.pnm
}

while [[ 1 == 1 ]]
do
    run
    if [[ $FAILED == 0 ]]
    then
        break
    fi
done
