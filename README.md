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
2. OOPS YOU ALSO NEED ON THE SYSTEM: `sudo pip3 install --target /lib/python3/dist-packages/ .`
3. Change shebang to python3 in arduinoudev.py.
4. Then install the arduino-udev-name bin script with `sudo cp arduino-udev-name /usr/bin`
5. The install the udev rules with `sudo cp udev/99-arduino-udev.rules /usr/lib/udev/rules.d/`
6. Then test `udevadm test $(udevadm info -q path -n /dev/ttyACM0)`
7. Hmm the test works. Then `sudo udevadm control --reload-rules`
8. But then unplug and plug and no love...
9. Ok so it doesn't have permissions to create the symlink. So i tried `sudo pip3 install .` of the arduino-python library - that enabled `sudo udevadm test...` to work, and would create the link, but not on plug in.
10. Side note a simple symlink to /dev/arduino that does not use the python code works. Not sure whether runs as root.
11. Oi vey!!! The problem was that when python runs under udev it has different path than when run (also as root?) from command line. It has limited package paths. So you must install the arduinoudev package to one of the system paths (i think, the method of adding the path to the script seemed terrible). `sudo pip3 install --target /lib/python3/dist-packages/ .` because that path is found during udev.
12. To troubleshoot this `journalctl -r` was critical. maybe also udevadm log debug.
13. Further notes are [here](https://github.com/aspence/spencelab/wiki/Udev-Treadmill-Arduino-Rules)

