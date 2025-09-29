#!/usr/bin/with-contenv bashio

PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo "I2C test starting..."
python3 /sensor/i2c-test.py

set -e
echo;echo;echo;echo;
echo "----DONE----  sleeping...";
sleep 99999;