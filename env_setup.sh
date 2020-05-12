#!/bin/sh

./install.sh emacs --with-gnutls=no
if [ $? -ne 0 ]; then
    exit -1
fi

./install.sh global
if [ $? -ne 0 ]; then
    exit -1
fi

./install.sh zlib
if [ $? -ne 0 ]; then
    exit -1
fi

./install.sh git --with-zlib=${PWD}/software/usr/local
if [ $? -ne 0 ]; then
    exit -1
fi
