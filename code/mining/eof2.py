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
	print(sstData.shape)
	pca = PCA(n_components=35)
	pca.fit_transform(np.transpose(sstData))
	pickle_data(np.transpose(pca.components_),"EOF",sstFile)
	print(np.transpose(pca.components_).shape)

if __name__ == "__main__":
	main()
