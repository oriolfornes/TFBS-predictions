#!/usr/bin/env python

from multiprocessing import Pool
import numpy as np
import os
import pandas as pd
from sklearn.metrics import (
    average_precision_score, matthews_corrcoef, roc_auc_score
)
from tqdm import tqdm

def compute_performances(args):

    performances = []

    tf, numpy_file, matrix_file = args

    with np.load(numpy_file) as handle:
        scores = handle["arr_0"]

    with np.load(matrix_file) as handle:
        matrix2d = handle["arr_0"]
    matrix1d = pd.DataFrame(matrix2d).max().to_numpy()

    nans = np.argwhere(np.isnan(matrix1d)).flatten()
    x = np.delete(scores, nans)
    y = np.delete(matrix1d, nans)

    if sum(y) == 0:
        return(tf, performances)

    for i in np.unique(x)[1:]:
        xi = x >= i
        performances.append([tf, i/1000., average_precision_score(y, xi),
            matthews_corrcoef(y, xi), roc_auc_score(y, xi)])

    return(tf, performances)

scripts_dir = os.path.dirname(os.path.realpath(__file__))
base_dir = os.path.join(scripts_dir, os.pardir)

files = []

for numpy_file in os.listdir(base_dir):

    if not numpy_file.endswith(".npz"):
        continue

    tf = numpy_file[:-4]

    matrix_file = "matrix2d.%s.ReMap+UniBind.sparse.npz" % tf
    if not os.path.exists(os.path.join(base_dir, "200bp", matrix_file)):
        continue

    tsv_file = os.path.join(base_dir, "%s.tsv.gz" % tf)
    if not os.path.exists(tsv_file):

        files.append((tf, os.path.join(base_dir, numpy_file),
            os.path.join(base_dir, "200bp", matrix_file)))

# Parallelize
kwargs = {
    "total": len(files),
    "ncols": 100
}
pool = Pool(1)
for tf, data in tqdm(pool.imap(compute_performances, files), **kwargs):
    tsv_file = os.path.join(base_dir, "%s.tsv.gz" % tf)
    df = pd.DataFrame(data, columns=["TF", "Score", "AUCPR", "MCC", "AUCROC"])
    df.to_csv(tsv_file, sep="\t", index=False, compression="gzip")
pool.close()
pool.join()
