#!/usr/bin/env bash

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

FASTA_FILE=${SCRIPTS_DIR}/../data/genomes/hg38/hg38.fa
INTERVALS_DIR=${SCRIPTS_DIR}/../intervals
SEQUENCES_DIR=${SCRIPTS_DIR}/../sequences

if ! [ -d ${SEQUENCES_DIR} ]; then
    mkdir ${SEQUENCES_DIR}
fi

for TF in `ls ${INTERVALS_DIR}/`; do

    if ! [ -d ${SEQUENCES_DIR}/${TF} ]; then
        mkdir ${SEQUENCES_DIR}/${TF}
    fi

    for I in `ls ${INTERVALS_DIR}/${TF}`; do

        if ! [ -d ${SEQUENCES_DIR}/${TF}/${I} ]; then
            mkdir ${SEQUENCES_DIR}/${TF}/${I}
        fi

        for  J in `ls ${INTERVALS_DIR}/${TF}/${I}`; do

            if ! [ -d ${SEQUENCES_DIR}/${TF}/${I}/${J} ]; then
                mkdir ${SEQUENCES_DIR}/${TF}/${I}/${J}
            fi

            for FILE in "Test" "Train+Validation"; do

                INTERVALS_FILE=${INTERVALS_DIR}/${TF}/${I}/${J}/${FILE}.bed
                SEQUENCES_FILE=${SEQUENCES_DIR}/${TF}/${I}/${J}/${FILE}.fa

                if [ -f ${INTERVALS_FILE} ]; then
                    if ! [ -f ${SEQUENCES_FILE} ]; then
                        bedtools getfasta -fi ${FASTA_FILE} \
                            -bed ${INTERVALS_FILE} \
                            -fo ${SEQUENCES_FILE}
                    fi
                fi

            done

        done

    done

done