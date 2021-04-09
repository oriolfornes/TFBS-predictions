#!/usr/bin/env bash

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd ${SCRIPTS_DIR}

# https://academic.oup.com/bioinformatics/article/34/14/2483/4921176
curl -L -O https://sourceforge.net/projects/pwmscan/files/pwmscan/rel-1.1.9/pwmscan.1.1.9.tar.gz
tar xvfz pwmscan.1.1.9.tar.gz
cd pwmscan
mkdir -p bin
make clean && make cleanbin
make && make install
cd ..
rm pwmscan.1.1.9.tar.gz
