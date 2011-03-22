#!/bin/bash
base=/u/c/s/cs537-1/ta
python=/unsup/python/bin/python
project=p3
$python "$base/tests/$project/run-tests.py" --project $project --project_path "`pwd`" $@
exit $?
