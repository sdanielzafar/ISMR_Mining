import numpy as np
import argparse
import csv
from sklearn.preprocessing import Imputer
import pickle
from sklearn import preprocessing

def read_file(fileName):
	data = np.zeros((3168,3,1308))
	with open(fileName,"rb") as f:
		reader = csv.reader(f)
		next(reader, None)
		curRow = 0
		curPlane = 0
		for row in reader:
			row = list(row)
			if (curRow == 3168):
				curRow = 0
				curPlane += 1
			else:
				data[curRow,0,curPlane] = float(row[0][:-1])
				data[curRow,1,curPlane] = float(row[1][:-1])
				data[curRow,2,curPlane] = float(row[-1])
				curRow += 1

	return data

def imput_data(data):
	numSubsets = data.shape[-1]
	for i in range(numSubsets):
		imp = Imputer(missing_values='NaN', strategy='mean', axis=0)
		imp.fit(data[:,:,i])
		data[:,:,i] = imp.transform(data[:,:,i])
		#data[:,-1,i] = preprocessing.scale(data[:,-1,i])
	return data

def pickle_data(data,fileName):
        with open(fileName[:-4]+'_scaled.pkl', 'wb') as f:
                pickle.dump(data,f)


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument('-p', type=str, help="Precipitation data file", required=True)
	args = parser.parse_args()
	precFile = args.p 
	precData = read_file(precFile)
	precData = imput_data(precData)
	print(precData[0,:,0])
	pickle_data(precData,precFile)

if __name__ == "__main__":
	main()
