#!/bin/sh -x

sudo apt-get install libmodule-install-perl libdata-dump-perl libjson-xs-perl libdigest-crc-perl libpod-readme-perl libdevice-serialport-perl
perl Makefile.PL
