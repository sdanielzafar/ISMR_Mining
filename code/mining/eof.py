import numpy as np
import argparse
from sklearn.decomposition import PCA
from data_stuff import *


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument('-s',type=str, help="SST pickle file", required=True)
	args = parser.parse_args()
	sstFile = args.s
	sstData = load_data(sstFile)
	pca = PCA()
	pca.fit(sstData)
	pickle_data(pca,sstFile)
	print(pca.explained_variance_ratio_)

if __name__ == "__main__":
	main()
