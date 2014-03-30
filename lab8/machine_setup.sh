#!/bin/bash

# Create certificate for the cluster (so we can connect w/ HTTPS and not
# send cleartext password).
#pushd /root
#openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout mycert.pem -out mycert.pem
#popd

# Create a python profile to use.
ipython profile create default

PASSWD="shiv"
python -c "from IPython.lib import passwd; print passwd('shiv')" > /root/.ipython/profile_default/nbpasswd.txt

cp ipython_notebook_config.py /root/.ipython/profile_default/ipython_notebook_config.py
# Naming controls order that these scripts are called; use 00 so this comes first.
cp pyspark-setup.py /root/.ipython/profile_default/startup/00-pyspark-setup.py
cp mycert.pem /root/

echo "Starting ipython notebook in screen..."
# Start the screen in detached mode.
screen -d -m ipython notebook
