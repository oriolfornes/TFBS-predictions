#!/usr/bin/env bash

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

FASTA_FILE=${SCRIPTS_DIR}/../data/genomes/hg38/hg38.fa
GIMMEMOTIFS_DIR=${SCRIPTS_DIR}/../gimmemotifs
JOBS_DIR=${SCRIPTS_DIR}/../jobs
INTERVALS_DIR=${SCRIPTS_DIR}/../intervals
SEQUENCES_DIR=${SCRIPTS_DIR}/../sequences

COUNTER=0


if ! [[ -d ${JOBS_DIR} ]]; then
    mkdir ${JOBS_DIR}
fi

for TF in `ls ${INTERVALS_DIR}`; do

    for I in `ls ${INTERVALS_DIR}/${TF}`; do

        INTERVALS_FILE=${INTERVALS_DIR}/${TF}/${I}/1/Train.bed
        SEQUENCES_FILE=${SEQUENCES_DIR}/${TF}/${I}/0/Train.fa

        if [[ -f ${INTERVALS_FILE} && -f ${SEQUENCES_FILE} ]]; then

            JOB_FILE=${JOBS_DIR}/${COUNTER}.sh

            echo "cd ${SCRIPTS_DIR}/.." >> ${JOB_FILE}
            echo 'eval "$(/home/ofornes/scratch/Miniconda3/bin/conda shell.bash hook)"' >> ${JOB_FILE}
            echo "conda activate gimme" >> ${JOB_FILE}
            echo "gimme motifs ${INTERVALS_FILE} ${GIMMEMOTIFS_DIR}/${TF}/${I} \\" >> ${JOB_FILE}
            echo "    -b ${SEQUENCES_FILE} -g ${FASTA_FILE} -t Homer,MEME --denovo" >> ${JOB_FILE}

            let "COUNTER++"

        fi

    done

done