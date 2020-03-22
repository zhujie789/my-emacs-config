#!/bin/bash

set -x

install_emacs() {
    EMACS_INSTALL_FILE_NAME=`ls emacs*.tar.gz`
    EMACS_INSTALL_DIR_NAME=${EMACS_INSTALL_FILE_NAME//.tar.gz/}

    if [ ! -d "${EMACS_INSTALL_DIR_NAME}" ]; then
	tar xzvf $EMACS_INSTALL_FILE_NAME
	if [ $? -ne 0 ]; then
	    exit 2
	fi
    fi

    cd $EMACS_INSTALL_DIR_NAME
    if [ ! -f "Makefile" ]; then
	./configure $*
	if [ $? -ne 0 ]; then
	    exit 2
	fi
    fi

    if [ ! -f "src/emacs" ]; then
	make
    fi

    grep "PATH=.*emacs" ~/.bashrc > /dev/null
    if [ $? -ne 0 ]; then
	echo "PATH=\${PATH}:${PWD}/src" >> ~/.bashrc
    fi

    grep "user-emacs-directory" ~/.emacs > /dev/null
    if [ $? -ne 0 ]; then
	echo "(setq user-emacs-directory \"${EMACS_CONFIG_PATH}/emacs.d\")" > ${HOME}/.emacs
	echo "(load-file \"${EMACS_CONFIG_PATH}/init.el\")" >> ${HOME}/.emacs
    fi
}

ALL_PARAMS=$*
EMACS_CONFIG_PATH=${PWD}
cd software

if [ $# -lt 1 ]; then
    echo "para error!"
    echo "usage: ./install.sh [emacs|global] ..."
    exit 2
fi

if [ $1 == "emacs" ]; then
    install_emacs ${ALL_PARAMS//emacs/}
elif [  $1 == "global" ]; then
    echo "install global done."
fi
