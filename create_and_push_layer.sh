#!/bin/bash

pip install numpy --no-cache-dir --upgrade -t python/lib/python3.8/site-packages/

find . | grep -E '(__pycache__|\.pyc|\.pyo$)' | xargs rm -rf

zip -r ./output/lambda_layer_payload.zip ./python > /dev/null



