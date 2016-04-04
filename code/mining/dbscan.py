import numpy as np
import argparse
from data_stuff import *
from sklearn.cluster import DBSCAN

def dbscanz(data):
	clusterSet = []
	setSize = data.shape[-1]
	db = DBSCAN()
	for i in range(setSize):
		db.fit(data[:,:,i])
		clustering = db.labels_
		numClusters = len(set(clustering)) - (1 if -1 in clustering else 0)
		means = np.zeros(numClusters)
		for j in range(numClusters):
			inds = np.where(clustering == j)[0]
			means[j] = np.mean(data[inds,2,j])
		clusterSet.append((clustering,means))
		
	return clusterSet

def main():
	parser = argparse.ArgumentParser()
        parser.add_argument('-p',type=str, help="Precip pickle file", required=True)
        args = parser.parse_args()
        precFile = args.p
        precData = load_data(precFile)
	clustering = dbscanz(precData)
	pickle_data(clustering,precFile)
	print(clustering)



if __name__ == "__main__":
	main()
