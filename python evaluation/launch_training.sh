#!/bin/bash
python3 nids_svm_model.py
python3 nids_keras_model.py
python3 nids_randomforest_model.py
python3 nids_xgboost_gradient_model.py