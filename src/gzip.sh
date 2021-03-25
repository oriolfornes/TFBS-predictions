#!/usr/bin/env bash

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

INTERVALS_DIR=${SCRIPTS_DIR}/../intervals
SEQUENCES_DIR=${SCRIPTS_DIR}/../sequences

for FILE in `find ${INTERVALS_DIR} -type f`; do

    if [ ${FILE: -4} == ".bed" ]; then
        gzip ${FILE}
    fi

done

for FILE in `find ${SEQUENCES_DIR} -type f`; do

    if [ ${FILE: -3} == ".fa" ]; then
        gzip ${FILE}
    fi

done