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

def get_coordinates(tf):

    numpy_file = "matrix2d.%s.ReMap+UniBind.sparse.npz" % tf

    with np.load(os.path.join(matrix_dir, numpy_file)) as handle:
        matrix2d = handle["arr_0"]
    matrix1d = pd.DataFrame(matrix2d).max().to_numpy()

    nonnan = np.argwhere(~np.isnan(matrix1d)).flatten()

    bed_file = os.path.join(coordinates_dir, "%s.bed" % tf)
    if not os.path.exists(bed_file):
        s = "\n".join([" ".join(regions[i]) for i in nonnan if matrix1d[i] == 1])
        a = BedTool(s, from_string=True)
        a.saveas(bed_file)

matrix2genes = {}

scripts_dir = os.path.dirname(os.path.realpath(__file__))
matrix_dir = os.path.join(scripts_dir, os.pardir, "data", "TF-Binding-Matrix")
coordinates_dir = os.path.join(scripts_dir, os.pardir, "coordinates")
if not os.path.isdir(coordinates_dir):
    os.makedirs(coordinates_dir)

with gzip.open(os.path.join(matrix_dir, "regions_idx.pickle.gz"), "rb") as f:
    regions_idx = pickle.load(f)
regions = np.array([k for k in regions_idx.keys()])

with gzip.open(os.path.join(matrix_dir, "tfs_idx.pickle.gz"), "rb") as f:
    tfs = pickle.load(f)

# Parallelize
kwargs = {
    "total": len(tfs),
    "ncols": 100
}
pool = Pool(4)
for _ in tqdm(pool.imap(get_coordinates, tfs), **kwargs):
    pass
pool.close()
pool.join()
