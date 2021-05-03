#!/usr/bin/env python

from Bio import SeqIO
from Bio.Seq import Seq
import gzip
import h5py
import hashlib
from multiprocessing import Pool
import numpy as np
import os
import pandas as pd
import pickle
from pybedtools.bedtool import BedTool
from tqdm import tqdm
import warnings
warnings.filterwarnings("ignore")

src_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), os.pardir)

intervals_dir = os.path.join(src_dir, os.pardir, "intervals", "Fig7")
if not os.path.isdir(intervals_dir):
    os.makedirs(intervals_dir)

matrix_dir = os.path.join(src_dir, os.pardir, "data", "TF-Binding-Matrix")

with gzip.open(os.path.join(matrix_dir, "regions_idx.pickle.gz"), "rb") as f:
    regions_idx = pickle.load(f)
regions = np.array([k for k in regions_idx.keys()])

tfs = [
    "ATF7",
    "ERG",
    "ETV4",
    "HNF4A",
    "JUND",
    "KLF9",
    "MAX",
    "MEF2A",
    "MNT",
    "NFE2L1",
    "NR2C2",
    "SP1",
    "SPI1",
    "SREBF2",
    "VDR",
    "ZNF740",
]

sequences = {}

for fasta_file in os.listdir(matrix_dir):

    if not fasta_file.startswith("sequences.200bp."):
        continue

    with gzip.open(os.path.join(matrix_dir, fasta_file), "rt") as handle:

        for record in SeqIO.parse(handle, "fasta"):

            ix, _ = record.id.split("::")
            md5 = hashlib.md5(str(record.seq).upper().encode()).hexdigest()
            sequences.setdefault(md5, int(ix))

tl_dir = os.path.join(src_dir, os.pardir, "data", "TL", "Fig7")

def one_hot_decode(encoded_seq):
    """Reverts a sequence's one hot encoding."""

    seq = []
    code = list("ACGT")
 
    for i in encoded_seq.transpose(1, 0):
        try:
            seq.append(code[int(np.where(i == 1)[0])])
        except:
            # i.e. N?
            seq.append("N")

    return("".join(seq))

def get_intervals(tf):

    numpy_file = "matrix2d.%s.ReMap+UniBind.sparse.npz" % tf

    with np.load(os.path.join(matrix_dir, numpy_file)) as handle:
        matrix2d = handle["arr_0"]
    matrix1d = pd.DataFrame(matrix2d).max().to_numpy()

    for sub_dir in os.listdir(tl_dir):

        if not os.path.isdir(os.path.join(tl_dir, sub_dir)):
            continue

        for i in range(1, 6):

            arr = []

            h5_file = os.path.join(tl_dir, sub_dir, "Train", "%s_indiv_%s" % \
                (tf, i), "h5_files", "%s_tl.h5" % tf)

            if not os.path.exists(h5_file):
                continue

            data = h5py.File(h5_file, "r")

            train = np.array([int(j.decode()) for j in data["train_headers"]])
            validation = np.array([int(j.decode()) for j in data["valid_headers"]])
            for encoded_seq in data["test_in"]:
                seq = Seq(one_hot_decode(encoded_seq))
                md5 = hashlib.md5(str(seq).encode()).hexdigest()
                if md5 in sequences:
                    arr.append(sequences[md5])
            test = np.array(arr)

            if len(train) == 0 or len(validation) == 0 or len(test) == 0:
                continue

            tf_dir = os.path.join(intervals_dir, sub_dir, tf)

            for j in range(2):

                if not os.path.isdir(os.path.join(tf_dir, str(i), str(j))):
                    os.makedirs(os.path.join(tf_dir, str(i), str(j)))

                bed_file = os.path.join(tf_dir, str(i), str(j), "Train.bed")
                if not os.path.exists(bed_file):
                    s = "\n".join([" ".join(regions[ix]) \
                        for ix in np.sort(train) \
                            if matrix1d[ix] == j])
                    a = BedTool(s, from_string=True)
                    a.saveas(bed_file)

                bed_file = os.path.join(tf_dir, str(i), str(j), "Validation.bed")
                if not os.path.exists(bed_file):
                    s = "\n".join([" ".join(regions[ix]) \
                        for ix in np.sort(validation) \
                            if matrix1d[ix] == j])
                    a = BedTool(s, from_string=True)
                    a.saveas(bed_file)

                bed_file = os.path.join(tf_dir, str(i), str(j), "Test.bed")
                if not os.path.exists(bed_file):
                    s = "\n".join([" ".join(regions[ix]) \
                        for ix in np.sort(test) \
                            if matrix1d[ix] == j])
                    a = BedTool(s, from_string=True)
                    a.saveas(bed_file)

# Parallelize
kwargs = {"total": len(tfs), "ncols": 100}
pool = Pool(4)
for _ in tqdm(pool.imap(get_intervals, tfs), **kwargs):
    pass
pool.close()
pool.join()
