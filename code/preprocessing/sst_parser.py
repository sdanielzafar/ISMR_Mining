import numpy as np
from sklearn.preprocessing import Imputer
import argparse
import csv
import pickle

def read_file(fileName):
	data = []
	with open(fileName,"rb") as f:
		reader = csv.reader(f)
		next(reader, None)
		for row in reader:
				row = list(row)[1:]
				row = map(float,row)
				data.append(row)	
	return np.array(data)
def parse_sst(sstData):
	numRows = len(sstData[0])
	numPointsMonth = numRows/1946
	data = np.zeros((numPointsMonth*88,1946))
	for month in range(1946):
		monthData = sstData[:,(numPointsMonth*month):(numPointsMonth*month+numPointsMonth)]
		monthData = np.reshape(monthData,numPointsMonth*88)
		data[:,month] = monthData
	
	return data

def pickle_data(data,fileName):
	with open(fileName[:-4]+'.pkl', 'wb') as f:
		pickle.dump(data,f)

def main():
	parser = argparse.ArgumentParser()
	parser.add_argument('-s', type=str, help="SST data file", required=True)
	parser.add_argument('-p', type=str, help="Precipitation data file")
	args = parser.parse_args()
	sstFile = args.s
	precFile = args.p 
	sstData = read_file(sstFile)
	sstData = np.transpose(parse_sst(sstData))[564:-74,:]
	imp = Imputer(missing_values='NaN', strategy='mean', axis=0)
	imp.fit(sstData)
	pickle_data(imp.transform(sstData),sstFile)

if __name__ == "__main__":
	main()
