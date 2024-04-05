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
