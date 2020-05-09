import pandas as pd
import numpy as np
from keras import regularizers
from keras.utils import to_categorical
from keras.models import Sequential
from keras.layers import Dense
from keras.layers import Dropout
from sklearn.model_selection import train_test_split as splitter
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
    y_train = to_categorical(y_train)
    y_test = to_categorical(y_test)
    val_indices = 200
    x_val = x_train[-val_indices:]
    y_val = y_train[-val_indices:]
    # train and test
    model = Sequential()
    model.add(Dense(1024, activation='relu', input_dim=x_train.shape[1], kernel_regularizer=regularizers.l2(0.001)))
    model.add(Dense(1024, activation='relu', kernel_regularizer=regularizers.l2(0.001)))
    model.add(Dropout(0.5))
    model.add(Dense(1024, activation='relu', kernel_regularizer=regularizers.l2(0.001)))
    model.add(Dense(1024, activation='relu', kernel_regularizer=regularizers.l2(0.001)))
    model.add(Dropout(0.5))
    model.add(Dense(1024, activation='relu', kernel_regularizer=regularizers.l2(0.001)))
    model.add(Dense(1024, activation='relu', kernel_regularizer=regularizers.l2(0.001)))
    model.add(Dropout(0.5))
    model.add(Dense(512, activation='relu', kernel_regularizer=regularizers.l2(0.001)))
    model.add(Dense(512, activation='relu', kernel_regularizer=regularizers.l2(0.001)))
    model.add(Dense(5, activation='softmax'))
    model.compile(loss='categorical_crossentropy', optimizer='rmsprop', metrics=['accuracy'])
    model.fit(x_train, y_train, epochs=15, batch_size=512, validation_data=(x_val, y_val))
    y_pred = model.predict(x_test)
    profile.disable()
    y_pred = np.argmax(y_pred, axis=1)
    y_test = np.argmax(y_test, axis=1)
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
    train_and_test('keras_kdd', data)
    data = pd.read_csv('./dataset/kdd_prediction_NSL.csv', delimiter=',',
                       dtype={'protocol_type': str, 'service': str, 'flag': str, 'result': str})
    train_and_test('keras_nsl_kdd', data)
