#!/bin/bash

set -x

install_software() {
    configure_params=${all_params//${software_name}/}
    software_package=`ls ${software_name}*.tar.gz`
    software_unpack_dir=${software_package//.tar.gz/}
    local_usr_path=${PWD}/usr/local

    if [ ! -d "${local_usr_path}" ]; then
	mkdir -p ${local_usr_path}
    fi

    if [ ! -d "${software_unpack_dir}" ]; then
	tar xzvf $software_package
	if [ $? -ne 0 ]; then
	    exit 2
	fi
    fi

    cd $software_unpack_dir
    ./configure --prefix=${local_usr_path} ${configure_params} && make && make install
}

if [ $# -lt 1 ]; then
    echo "para error!"
    echo "usage: ./install.sh [emacs|global|git] ..."
    exit 2
fi

all_params=$*
software_name=$1
emacs_config_path=${PWD}

cd software && install_software

if [ $? -ne 0 ]; then
    exit 2
fi

grep "user-emacs-directory" ~/.emacs > /dev/null
if [ $? -ne 0 ]; then
    echo "(setq user-emacs-directory \"${emacs_config_path}/emacs.d\")" > ${HOME}/.emacs
    echo "(load-file \"${emacs_config_path}/init.el\")" >> ${HOME}/.emacs
fi

grep "PATH=.*${local_usr_path}/bin" ~/.bashrc > /dev/null
if [ $? -ne 0 ]; then
    echo "PATH=${local_usr_path}/bin:\${PATH}" >> ~/.bashrc
fi
