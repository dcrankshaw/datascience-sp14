#!/bin/bash

for i in `ls *.ipynb`
do
  echo $i
  filename=$(basename "$i")
  extension="${filename##*.}"
  filename="${filename%.*}"

  ipython nbconvert --template=python-output.tpl --to python $i
  sed -i 's/DATA_PATH =.*/DATA_PATH=\"\/home\/saasbook\/datascience-sp14\/hw2\"/g' "$filename.py"
  sed -i 's/pylab inline/pylab/g' "$filename.py"
  echo "Created $filename.py"
  mv $filename.py python_files_fixed/ 
done
