#!/usr/bin/env bash

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

JOBS_DIR=${SCRIPTS_DIR}/../streme-jobs
COUNTER=0

if ! [[ -d ${JOBS_DIR} ]]; then
    mkdir ${JOBS_DIR}
fi

SRC_ACT_CONDA_ENV="source activate /scratch/ex-ofornes-1/.conda/envs/meme"

SEQUENCES_DIR=${SCRIPTS_DIR}/../sequences/Fig3
STREME_DIR=${SCRIPTS_DIR}/../streme/Fig3

for TF in `ls ${SEQUENCES_DIR}`; do

    for I in `ls ${SEQUENCES_DIR}/${TF}`; do

        POS_FASTA_FILE=${SEQUENCES_DIR}/${TF}/${I}/1/Train.fa
        NEG_FASTA_FILE=${SEQUENCES_DIR}/${TF}/${I}/0/Train.fa

        if [[ -f ${POS_FASTA_FILE} && -f ${POS_FASTA_FILE} ]]; then
            if ! [[ -d ${STREME_DIR}/${TF}/${I} ]]; then

                JOB_FILE=${JOBS_DIR}/${COUNTER}.sh

                echo "cd ${SCRIPTS_DIR}/.." > ${JOB_FILE}
                echo "${SRC_ACT_CONDA_ENV}" >> ${JOB_FILE}
                echo "mkdir -p ${STREME_DIR}/${TF}/${I}" >> ${JOB_FILE}
                echo "streme --p ${POS_FASTA_FILE} \\" >> ${JOB_FILE}
                echo "    --n ${NEG_FASTA_FILE} \\" >> ${JOB_FILE}
                echo "    --text \\" >> ${JOB_FILE}
                echo "    --maxw 21 \\" >> ${JOB_FILE}
                echo "    --nmotifs 5 \\" >> ${JOB_FILE}
                echo "    --hofract 0 \\" >> ${JOB_FILE}
                echo "    --verbosity 2 \\" >> ${JOB_FILE}
                echo "    > ${STREME_DIR}/${TF}/${I}/streme.txt" >> ${JOB_FILE}

                let "COUNTER++"

            fi
        fi

    done

done

SEQUENCES_DIR=${SCRIPTS_DIR}/../sequences/Fig7
STREME_DIR=${SCRIPTS_DIR}/../streme/Fig7

for SUB_DIR in `ls ${SEQUENCES_DIR}`; do

    for TF in `ls ${SEQUENCES_DIR}/${SUB_DIR}`; do

        for I in `ls ${SEQUENCES_DIR}/${SUB_DIR}/${TF}`; do

            POS_FASTA_FILE=${SEQUENCES_DIR}/${SUB_DIR}/${TF}/${I}/1/Train.fa
            NEG_FASTA_FILE=${SEQUENCES_DIR}/${SUB_DIR}/${TF}/${I}/0/Train.fa

            if [[ -f ${POS_FASTA_FILE} && -f ${POS_FASTA_FILE} ]]; then
                if ! [[ -d ${STREME_DIR}/${SUB_DIR}/${TF}/${I} ]]; then

                    JOB_FILE=${JOBS_DIR}/${COUNTER}.sh

                    echo "cd ${SCRIPTS_DIR}/.." > ${JOB_FILE}
                    echo "${SRC_ACT_CONDA_ENV}" >> ${JOB_FILE}
                    echo "mkdir -p ${STREME_DIR}/${SUB_DIR}/${TF}/${I}" >> ${JOB_FILE}
                    echo "streme --p ${POS_FASTA_FILE} \\" >> ${JOB_FILE}
                    echo "    --n ${NEG_FASTA_FILE} \\" >> ${JOB_FILE}
                    echo "    --text \\" >> ${JOB_FILE}
                    echo "    --maxw 21 \\" >> ${JOB_FILE}
                    echo "    --nmotifs 5 \\" >> ${JOB_FILE}
                    echo "    --hofract 0 \\" >> ${JOB_FILE}
                    echo "    --verbosity 2 \\" >> ${JOB_FILE}
                    echo "    > ${STREME_DIR}/${SUB_DIR}/${TF}/${I}/streme.txt" >> ${JOB_FILE}

                    let "COUNTER++"

                fi
            fi

        done

    done

done

