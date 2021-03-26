#!/usr/bin/env bash

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

INTERVALS_DIR=${SCRIPTS_DIR}/../intervals
SEQUENCES_DIR=${SCRIPTS_DIR}/../sequences

for F in `find ${INTERVALS_DIR} -type f`; do

    if [ ${F: -3} == ".gz" ]; then
        gunzip ${F}
    fi

done

for F in `find ${SEQUENCES_DIR} -type f`; do

    if [ ${F: -3} == ".gz" ]; then
        gunzip ${F}
    fi

done