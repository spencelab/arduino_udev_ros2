arduino-udev
============

testing udev rules
------------------

    udevadm test $(udevadm info -q path -n /dev/ttyUSB0)
    udevadm control --reload-rules

getting and setting device name
-------------------------------

get name

./arduino-udev-name /dev/tty.usbmodem2101

set name

./arduino-udev-name --set-name trig5 --verbose /dev/tty.usbmodem2101

Note for above to work you have to install arduinoudev.py in site-packages or elsewhere in the python path.

And you will need pyserial in the Python install. On linux system wide could be pip3 install pyserial.

On mac with conda obviously conda activate <env>, eg triggerbox_ros2 on ajs mac; conda install pyserial.

more extensive notes on function and porting
--------------------------------------------
https://github.com/aspence/spencelab/wiki/Strawlab-Triggerbox

install
-------
Ok also - Strawlab has updated theirs for py3 compatibility and has a setup.py. On Ubuntu 22, can clone and install, by going into the dir and set it all up with 

1. `pip3 install .` This puts arduinoudev python library in your python3 site packages or similar.
2. Change shebang to python3 in arduinoudev.py.
3. Then install the arduino-udev-name bin script with `sudo cp arduino-udev-name /usr/local/bin`
4. The install the udev rules with `sudo cp udev/99-arduino-udev.rules /usr/lib/udev/rules.d/`
5. Then test `udevadm test $(udevadm info -q path -n /dev/ttyACM0)`
6. Hmm getting errors it's missing the /dev when calls the function... i remember a note about this in the code.

`
