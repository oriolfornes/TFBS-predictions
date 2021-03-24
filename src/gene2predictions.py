#!/usr/bin/env python

from Bio import SeqIO
import json
from multiprocessing import Pool
import numpy as np
import os
import pandas as pd
from tqdm import tqdm

def gene_to_predictions(gene):

    scores = np.zeros(len(seq2region))

    for chrom in chroms:

        for matrix in gene2matrices[gene]:

            tsv_file = os.path.join(scripts_dir, os.pardir, chrom,
                "%s.tsv.gz" % matrix)
            df = pd.read_csv(tsv_file, sep="\t", usecols=[0, 4],
                names=["Seq", "Score"])
            for _, row in df.iterrows():
                region = seq2region[row["Seq"]]
                if row["Score"] > scores[region]:
                    scores[region] = row["Score"]

    np.savez_compressed(
        os.path.join(scripts_dir, os.pardir, "%s.npz" % gene), scores
    )

scripts_dir = os.path.dirname(os.path.realpath(__file__))
json_file = os.path.join(scripts_dir, os.pardir, "matrix2genes.json")

seq2region = {}

for fasta_file in os.listdir(os.path.join(scripts_dir, os.pardir)):
    if not fasta_file.endswith(".fa"):
        continue
    for record in SeqIO.parse(
        os.path.join(scripts_dir, os.pardir, fasta_file), "fasta"
    ):
        region, _ = record.id.split("::")
        seq2region.setdefault(record.id, int(region))

gene2matrices = {}

with open(json_file, "rt") as f:
    matrix2genes = json.load(f)

for matrix, genes in matrix2genes.items():
    for gene in genes:
        gene2matrices.setdefault(gene, list())
        gene2matrices[gene].append(matrix)

chroms = ["chr%s" % j for j in [i + 1 for i in range(22)] + list("XY")]

# Parallelize
kwargs = {
    "total": len(gene2matrices),
    "ncols": 100
}
pool = Pool(8)
for _ in tqdm(pool.imap(gene_to_predictions, gene2matrices), **kwargs):
    pass
pool.close()
pool.join()