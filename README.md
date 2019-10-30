# pySICL
Keysight SICL for Python

This is project is using cython include Keysight IO library.
Execute command below:
python setup.py build_ext --inplace


# Basic usage

from pySICL import sicl

gpib = sicl.SICL("gpib1", "\n")
res = gpib.ipromptf("*IDN?")  # ipromptf perform a formatted write immediately followed by a formatted read

gpib.iprintf("*IDN?")
res = gpib.iscanf()  # read formatted data


# How to use bus trigger

from pySICL import sicl

gpib = sicl.SICL("gpib1", "\n")  # This is interface session
gpib1 = sicl.SICL("gpib1,1", "\n")  # This is device session which is connected to gpib1 interface
gpib2 = sicl.SICL("gpib1,2", "\n")  # This is device session which is connected to gpib1 interface

gpib.igpibsendcmd(bytes([0x3F, 0x20 + 1, 0x20 + 1]).decode('utf-8'))  # 0x3F makes all device unlisten,
                                                                      # 0x20 + 1 makes address 1 to be listener
                                                                      # 0x20 + 2 makes address 2 to be listener
gpib.itrigger()  # start trigger
