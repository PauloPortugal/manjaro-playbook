#!/bin/bash

# Only install if package does not exist
if [ $(pip show ${1}) == 1 ]; then
  pip install ${1}
else
  exit -1;
fi
