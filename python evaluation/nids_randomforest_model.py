import pandas as pd
from sklearn.model_selection import train_test_split as splitter
from sklearn.ensemble import RandomForestClassifier
import cProfile
import pstats
import os
import sys
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.preprocessing import LabelEncoder

__version__ = "0.1"
__author__ = 'Benedetto Marco Serinelli'


def train_and_test(dataset, data):
    for column in data.columns:
        if data[column].dtype == type(object):
            le = LabelEncoder()
            data[column] = le.fit_transform(data[column])
    y = data.result
    x = data.drop('result', axis=1)
    profile = cProfile.Profile()
    x_train, x_test, y_train, y_test = splitter(x, y, test_size=0.3)
    profile.enable()
    # train and test
    regressor = RandomForestClassifier()
    regressor.fit(x_train, y_train)
    y_pred = regressor.predict(x_test)
    profile.disable()
    profile.dump_stats('output.prof')
    stream = open('result/'+dataset+'_profiling.txt', 'w')
    stats = pstats.Stats('output.prof', stream=stream)
    stats.sort_stats('cumtime')
    stats.print_stats()
    os.remove('output.prof')
    conf_matrix = confusion_matrix(y_test, y_pred)
    f = open('result/'+dataset+'_output.txt', 'w')
    sys.stdout = f
    print(conf_matrix)
    print(classification_report(y_test, y_pred))


if __name__ == "__main__":
    data = pd.read_csv('./dataset/kdd_prediction.csv', delimiter=',',
                       dtype={'protocol_type': str, 'service': str, 'flag': str, 'result': str})
    train_and_test('rf_kdd', data)
    data = pd.read_csv('./dataset/kdd_prediction_NSL.csv', delimiter=',',
                       dtype={'protocol_type': str, 'service': str, 'flag': str, 'result': str})
    train_and_test('rf_nsl_kdd', data)
