#!/usr/bin/env python

import gzip
from multiprocessing import Pool
import numpy as np
import os
import pandas as pd
import pickle
from pybedtools.bedtool import BedTool
import subprocess as sp
from tqdm import tqdm
import warnings
warnings.filterwarnings("ignore")

def motif_discovery(tf):

    tf_dir = os.path.join(motifs_dir, tf)
    if not os.path.isdir(tf_dir):
        os.makedirs(tf_dir)
    fasta_dir = os.path.join(tf_dir, "FASTA")
    if not os.path.isdir(fasta_dir):
        os.makedirs(fasta_dir)

    numpy_file = "matrix2d.%s.ReMap+UniBind.sparse.npz" % tf

    with np.load(os.path.join(matrix_dir, numpy_file)) as handle:
        matrix2d = handle["arr_0"]
    matrix1d = pd.DataFrame(matrix2d).max().to_numpy()

    nonnan = np.argwhere(~np.isnan(matrix1d)).flatten()

    # Coordinates
    pos_fasta = os.path.join(fasta_dir, "positives.fa")
    if not os.path.exists(pos_fasta):
        s = "\n".join([" ".join(regions[i]) for i in nonnan if matrix1d[i] == 1])
        a = BedTool(s, from_string=True)
        a = a.sequence(fi=genome_fasta)
        with open(pos_fasta, "w") as f:
            f.write(open(a.seqfn).read())

    # negative sequences
    neg_fasta = os.path.join(fasta_dir, "negative.fa")
    if not os.path.exists(neg_fasta):
        cmd = "biasaway k -f %s -e 1 > %s" % (pos_fasta, neg_fasta)
        _ = sp.run([cmd], shell=True, cwd=scripts_dir, stderr=sp.DEVNULL)

    exit(0)
    
    if not os.path.isdir(fasta_dir):
        os.makedirs(fasta_dir)

    # negative sequences

    print(matrix1d)
    exit(0)


matrix2genes = {}

scripts_dir = os.path.dirname(os.path.realpath(__file__))
genome_fasta = os.path.join(scripts_dir, os.pardir, "data", "hg38", "hg38.fa")
matrix_dir = os.path.join(scripts_dir, os.pardir, "data", "TF-Binding-Matrix")
motifs_dir = os.path.join(scripts_dir, os.pardir, "motifs")
if not os.path.isdir(motifs_dir):
    os.makedirs(motifs_dir)
yamda = os.path.join(scripts_dir, os.pardir, "bin", "yamda.py")

with gzip.open(os.path.join(matrix_dir, "regions_idx.pickle.gz"), "rb") as f:
    regions_idx = pickle.load(f)
regions = np.array([k for k in regions_idx.keys()])

with gzip.open(os.path.join(matrix_dir, "tfs_idx.pickle.gz"), "rb") as f:
    tfs = pickle.load(f)

motif_discovery("JUN")
exit(0)

# Parallelize
kwargs = {
    "total": len(tfs),
    "ncols": 100
}
pool = Pool(1)
for _ in tqdm(pool.imap(motif_discovery, tfs), **kwargs):
    pass
pool.close()
pool.join()
