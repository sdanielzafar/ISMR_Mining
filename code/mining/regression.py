from sklearn import svm
import numpy as np
from sklearn.metrics import mean_squared_error
from sklearn.metrics import r2_score

class RegressionData:
	
	def __init__(self, sst, clusters, windowSz):
		self.X = self.get_x(sst,clusters, windowSz)
		self.y = self.get_y(clusters,windowSz)

	def get_x(self, sst, prec, windowSz):
		x = []
		num_months = prec.shape[0]
		for i in range(num_months-windowSz):
			curXPart = np.append(sst[i], sst[i+1])
			numClusters = prec[i+2,1].shape[0]
			for j in range(numClusters):
				x.append(np.append(curXPart,j))
		return np.array(x)
		

	def get_y(self, prec, windowSz):
		y = []
		num_months = prec.shape[0]
		for i in range(windowSz,num_months):
			numClusters = prec[i,1].shape[0]
			for j in range(numClusters):
				y.append(prec[i,1][j])
		return np.array(y)

def svm_regression(X,y):
	svmR = svm.SVR()
	svmR.fit(X,y)
	return svmR

def eval(yHat, y):
	r2 = r2_score(y,yHat)
	mse = mean_squared_error(y,yHat)
	return (r2,mse)
