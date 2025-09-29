#!/usr/bin/with-contenv bashio

PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo "Create virtual environment"
mkdir /virtual_env
python3 -m venv /virtual_env
source /virtual_env/bin/activate

echo "Install packages"
python3 -m pip install smbus2
python3 -m pip install paho-mqtt

echo "I2C test starting..."
python3 /sensor/i2c-test.py

set -e
echo;echo;echo;echo;
echo "----DONE----  sleeping...";
sleep 99999;