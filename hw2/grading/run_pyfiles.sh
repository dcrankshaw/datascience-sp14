#!/bin/bash
pushd python_files_fixed

for i in `cat rerun` #`ls *.py`
do
  echo "Running $i"
  filename=$(basename "$i")
  extension="${filename##*.}"
  filename="${filename%.*}"

  timeout --kill-after=5m 20m ipython $i 2>&1 > $filename.out

done
popd
