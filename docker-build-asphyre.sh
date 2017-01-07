#!/bin/bash

function build {
    echo ......................... building $1/*.lpr
    rm -f *.bin *.elf *.img *.o *.ppu
    set -x
    docker run --rm -v $(pwd):/workdir markfirmware/ufpc \
     -Mdelphi \
     -B \
     -Tultibo \
     -O2 \
     -Parm \
     $2 \
     -Fu$1 \
     -FuSource \
     @/root/ultibo/core/fpc/bin/$3 \
     $1/*.lpr
    EXIT_STATUS=$?
    set +x
    if [ "$EXIT_STATUS" != 0 ]
    then
        exit 1
    fi
}

function build-QEMU {
    build $1 "-CpARMV7A -WpQEMUVPB" qemuvpb.cfg
}

function build-RPi {
    build $1 "-CpARMV6 -WpRPIB" rpi.cfg
}

function build-RPi2 {
    build $1 "-CpARMV7A -WpRPI2B" rpi2.cfg
}

function build-RPi3 {
    build $1 "-CpARMV7A -WpRPI3B" rpi3.cfg
}

function asphyre {
    SAMPLE=$1
    TARGET=$2
    build-$TARGET "$SAMPLE"
    mkdir -p $CIRCLE_ARTIFACTS/Asphyre/$SAMPLE/$TARGET
    cp -a kernel* $CIRCLE_ARTIFACTS/Asphyre/$SAMPLE/$TARGET
}

SAMPLES=Samples/FreePascal/Ultibo
for SAMPLE in $SAMPLES/*
do
    if [ "$SAMPLE" != "$SAMPLES/Media" ]
    then
        asphyre $SAMPLE RPi2
    fi
done
