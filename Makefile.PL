use inc::Module::Install;

name     'RFID-Serial';
all_from 'lib/RFID/Serial.pm';
author   q{Dobrica Pavlinusic <dpavlin@rot13.org>};
license  'gpl';

requires 'Carp';
requires 'Data::Dump';
requires 'Device::SerialPort';
requires 'Time::HiRes';

build_requires 'Test::More';

auto_install;

WriteAll;

