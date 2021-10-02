#!/bin/bash

rm -rf ./env
mkdir ./env
python3 -m venv ./env
source ./env/bin/activate
echo $(which pip)
pip install -r ./app/requirements.txt
