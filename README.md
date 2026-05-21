arduino-udev
============
TODO:
1. 5/21/2026: Try the install rules below with the draft code in the testing branch on camdev. If working, commit, for v=13 firmware. Should have complete updated triggerbox system them.
2. 
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

Oh wait you dummy...
```
spencelab@ros2test:~/strawlab_arduinoudev/arduino-udev$ ll /lib
lrwxrwxrwx 1 root root 7 Mar 20 11:57 /lib -> usr/lib/
```

The paths it has when i udev are:
```
Apr 18 13:28:40 ros2test systemd-udevd[5098]: ttyACM0: '/usr/bin/arduino-udev-name -w 2 ttyACM0'(out)
'['/usr/bin', '/lib/python310.zip', '/lib/python3.10',
'/lib/python3.10/lib-dynload', '/lib/python3/dist-packages']'
```

### merge update workflow

Yep, I diffed the two zips and made a minimal “bring in the useful upstream Ubuntu 24/Python 3 bits without nuking your ROS2 notes” patch.

Download the arduino_udev_ros2 Ubuntu 24 patch

It intentionally does not overwrite your README.md, because your local README has hard-won install/debug notes. I added a separate:

MERGE_NOTES_UBUNTU24.md
What this patch brings in

From upstream Strawlab arduino-udev commit:

bf690bb200dd21d75f4c50780e78a3d3eeedc833

it updates/adds:

src/arduinoudev.py
bin/arduino-udev-name
setup.py
MANIFEST.in
LICENSE.txt
AUTHORS.txt
.gitignore
udev/99-arduino-udev.rules
firmware/example2/example2.py
MERGE_NOTES_UBUNTU24.md

Main useful changes:

Python 3 serial bytes handling
Python 3-compatible CRC/name protocol
setup.py package install support
expanded udev rules for Arduino Uno IDs
upstream license/authors/package metadata

The biggest real fix is src/arduinoudev.py: your local version still had Python 2 style serial writes like 'N?', ord(c), and print "RAW", while upstream now uses bytes/bytearray correctly for Python 3.

Suggested branch/test flow
cd ~/ros2_ws/src/arduino_udev_ros2

git status
git switch -c ubuntu24-python3-upstream-merge
unzip -o /path/to/arduino_udev_ros2_ubuntu24_patch.zip

git diff

Quick import check:

python3 -m py_compile src/arduinoudev.py
PYTHONPATH=$PWD/src python3 -c "import arduinoudev; print('ok')"

Install/test on Ubuntu 24:

sudo apt update
sudo apt install python3-serial python3-pip

sudo python3 -m pip install --break-system-packages \
  --target /usr/lib/python3/dist-packages .

sudo install -m 0755 bin/arduino-udev-name /usr/bin/arduino-udev-name
sudo install -m 0644 udev/99-arduino-udev.rules /etc/udev/rules.d/99-arduino-udev.rules

sudo udevadm control --reload-rules
sudo udevadm trigger

Manual check:

arduino-udev-name -w 2 /dev/ttyACM0
udevadm test $(udevadm info -q path -n /dev/ttyACM0)

If udev gets grumpy:

journalctl -r -u systemd-udevd
One note

Upstream’s setup.py still has older classifiers like Python 3.8, but that does not block install on Ubuntu 24. It is package metadata dust, not runtime doom. The actual runtime code is simple pyserial + bytes handling, which is the important part.
