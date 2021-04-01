#!/usr/bin/env bash

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

INTERVALS_DIR=${SCRIPTS_DIR}/../intervals
SEQUENCES_DIR=${SCRIPTS_DIR}/../sequences
STREME_DIR=${SCRIPTS_DIR}/../streme

for F in `find ${INTERVALS_DIR} -type f`; do

    if [ ${F: -4} == ".bed" ]; then
        gzip ${F}
    fi

done

for F in `find ${SEQUENCES_DIR} -type f`; do

    if [ ${F: -3} == ".fa" ]; then
        gzip ${F}
    fi

done

# for F in `find ${STREME_DIR} -type f`; do

#     if [ ${F: -4} == ".txt" ]; then
#         gzip ${F}
#     fi

# done