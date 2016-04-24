from sklearn import svm
from sklearn import cross_validation
from sklearn import metrics
import numpy as np
from sklearn.decomposition import PCA
import argparse
import pickle

def load_data(fileName):
    with open(fileName) as f:
        data = pickle.load(f)
    return data

def PCA_data(X, N_components):
    pca = PCA(n_components=N_components)
    pca.fit(X.transpose())
    Xdata = pca.components_.transpose()
    return Xdata

# Accuracy(clf,Y2_test,Y_test)
def Accuracy_data(clf,y_predicted, y_actual):
    accuracy = []
    for i in xrange(len(clf)):
        accuracy.append(metrics.accuracy_score(y_actual[i],y_predicted[i]))
    #print accuracy
    print 'Accuracy: ',sum(accuracy)/len(accuracy)
    return accuracy

class ClassificationData:
    def __init__(self,Xdata,Ydata,sliding_factor=1, test_ratio=0.4):
        self.X = Xdata
        self.y = Ydata
        self.sliding_factor = sliding_factor
        self.test_ratio = test_ratio

    def Classification(self):
        #data = load_data(XDatafilename), N_components=35, Ydata = load_data(args.YdataFile)
        X_train = []
        X_test = []
        Y_train = []
        Y_test = []
        Y2_test = []

        Xdata = self.X
        Ydata = self.y

        clf = []
        sliding_factor = self.sliding_factor
        if sliding_factor>=1:
            Xdata1 = np.empty((Xdata.shape[0]-sliding_factor-1,Xdata.shape[1]*(sliding_factor+1)))
            index = 0
            for i in range(sliding_factor,len(Xdata)-1):
                data1 = np.empty(0)
                for j in range(sliding_factor,-1,-1):
                    data1 = np.append(data1,Xdata[i-j])
                Xdata1[index] = data1
                index += 1
        else:
            Xdata1 = Xdata

        for i in xrange(len(Ydata[0])):
            x_train, x_test, y_train, y_test = cross_validation.train_test_split(
                Xdata1, Ydata[sliding_factor+1:,i] if sliding_factor>=1 else Ydata[:,i],
                test_size=self.test_ratio, random_state=0)
            X_train.append(x_train)
            X_test.append(x_test)
            Y_train.append(np.concatenate(
                    (y_train[sliding_factor:],y_train[-sliding_factor:])))
            Y_test.append(np.concatenate(
                    (y_test[sliding_factor:],y_test[-sliding_factor:])))
            clf.append(svm.SVC(decision_function_shape='ovo'))
            clf[-1].fit(X_train[-1], Y_train[-1])
            Y2_test.append(clf[-1].predict(X_test[-1]))
        return clf,Y2_test,Y_test

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Data Mining')
    parser.add_argument('--XdataFile', type=str,
                            help="Location of Xdata",
                            default="EP10_parsed.pkl",
                            required=False)
    parser.add_argument('--YdataFile', type=str,
                            help="Location of Ydata",
                            default="sst_clust.pkl",
                            required=False)
    parser.add_argument('--n_components', type=int,
                            help="Number of Components for PCA",
                            default=35,
                            required=False)
    parser.add_argument('--sliding_factor', type=int,
                            help="Sliding Window Factor",
                            default=1,
                            required=False)
    args = parser.parse_args()

    Xdata = load_data(args.XdataFile)
    Ydata = load_data(args.YdataFile)
    Xdata = PCA_data(Xdata,args.sliding_factor)

    classificationData = ClassificationData(Xdata,Ydata,args.sliding_factor)
    clf,Y2_test,Y_test = classificationData.Classification()

    #clf,Y2_test,Y_test = SVC_data(Xdata,Ydata,args.sliding_factor)
    accuracy = Accuracy_data(clf,Y2_test,Y_test)
