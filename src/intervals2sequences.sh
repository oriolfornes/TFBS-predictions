#!/usr/bin/env bash

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

GENOME_FILE=${SCRIPTS_DIR}/../data/genomes/hg38/hg38.fa

INTERVALS_DIR=${SCRIPTS_DIR}/../intervals/Fig3
SEQUENCES_DIR=${SCRIPTS_DIR}/../sequences/Fig3

for TF in `ls ${INTERVALS_DIR}`; do

    for I in `ls ${INTERVALS_DIR}/${TF}`; do

        for  J in `ls ${INTERVALS_DIR}/${TF}/${I}`; do

            if ! [ -d ${SEQUENCES_DIR}/${TF}/${I}/${J} ]; then
                mkdir -p ${SEQUENCES_DIR}/${TF}/${I}/${J}
            fi

            for FILE in "Test" "Train" "Validation"; do

                PREFIXES=(${INTERVALS_DIR}/${TF}/${I}/${J} \
                    ${SEQUENCES_DIR}/${TF}/${I}/${J})

                if [ -f ${PREFIXES[1]}/${FILE}.fa.gz ]; then
                    continue
                fi

                if [ -f ${PREFIXES[0]}/${FILE}.bed ]; then
                    if ! [ -f ${PREFIXES[1]}/${FILE}.fa ]; then
                        bedtools getfasta -fi ${GENOME_FILE} \
                            -bed ${PREFIXES[0]}/${FILE}.bed \
                            -fo ${PREFIXES[1]}/${FILE}.fa
                    fi
                fi

            done

        done

    done

done

INTERVALS_DIR=${SCRIPTS_DIR}/../intervals/Fig7
SEQUENCES_DIR=${SCRIPTS_DIR}/../sequences/Fig7

for SUB_DIR in `ls ${INTERVALS_DIR}`; do

    for TF in `ls ${INTERVALS_DIR}/${SUB_DIR}`; do

        for I in `ls ${INTERVALS_DIR}/${SUB_DIR}/${TF}`; do

            for  J in `ls ${INTERVALS_DIR}/${SUB_DIR}/${TF}/${I}`; do

                if ! [ -d ${SEQUENCES_DIR}/${SUB_DIR}/${TF}/${I}/${J} ]; then
                    mkdir -p ${SEQUENCES_DIR}/${SUB_DIR}/${TF}/${I}/${J}
                fi

                for FILE in "Test" "Train" "Validation"; do

                    PREFIXES=(${INTERVALS_DIR}/${SUB_DIR}/${TF}/${I}/${J} \
                        ${SEQUENCES_DIR}/${SUB_DIR}/${TF}/${I}/${J})

                    if [ -f ${PREFIXES[1]}/${FILE}.fa.gz ]; then
                        continue
                    fi

                    if [ -f ${PREFIXES[0]}/${FILE}.bed ]; then
                        if ! [ -f ${PREFIXES[1]}/${FILE}.fa ]; then
                            bedtools getfasta -fi ${GENOME_FILE} \
                                -bed ${PREFIXES[0]}/${FILE}.bed \
                                -fo ${PREFIXES[1]}/${FILE}.fa
                        fi
                    fi

                done

            done

            for FILE in "Test-all" "Test-hard"; do

                PREFIXES=(${INTERVALS_DIR}/${SUB_DIR}/${TF}/${I}/0 \
                    ${SEQUENCES_DIR}/${SUB_DIR}/${TF}/${I}/0)

                if [ -f ${PREFIXES[1]}/${FILE}.fa.gz ]; then
                    continue
                fi

                if [ -f ${PREFIXES[0]}/${FILE}.bed ]; then
                    if ! [ -f ${PREFIXES[1]}/${FILE}.fa ]; then
                        bedtools getfasta -fi ${GENOME_FILE} \
                            -bed ${PREFIXES[0]}/${FILE}.bed \
                            -fo ${PREFIXES[1]}/${FILE}.fa
                    fi
                fi

            done

        done

    done

done