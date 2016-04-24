import pickle

def load_data(fileName):
        with open(fileName) as f:
                data = pickle.load(f)
        return data

def pickle_data(data,dataType,fileName):
        with open(fileName[:-4]+'_'+dataType+'.pkl', 'wb') as f:
                pickle.dump(data,f)

