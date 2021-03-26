SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

INTERVALS_DIR=${SCRIPTS_DIR}/../intervals
FASTA_FILE=${SCRIPTS_DIR}/../data/genomes/hg38/hg38.fa
SEQUENCES_DIR=${SCRIPTS_DIR}/../sequences
GIMMEMOTIFS_DIR=${SCRIPTS_DIR}/../gimmemotifs

for TF in `ls ${INTERVALS_DIR}`; do

    for I in `ls ${INTERVALS_DIR}/${TF}`; do

        INTERVALS_FILE=${INTERVALS_DIR}/${TF}/${I}/1/Train.bed
        SEQUENCES_FILE=${SEQUENCES_DIR}/${TF}/${I}/0/Train.fa

        if [[ -f ${INTERVALS_FILE} && -f ${SEQUENCES_FILE} ]]; then
            if ! [[ -d ${GIMMEMOTIFS_DIR}/${TF}/${I} ]]; then
                gimme motifs ${INTERVALS_FILE} \
                    ${GIMMEMOTIFS_DIR}/${TF}/${I} \
                    -b ${SEQUENCES_FILE} \
                    -g ${FASTA_FILE} \
                    -t Homer,MEME \
                    --denovo
            fi
        fi

    done

done