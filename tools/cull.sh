#!/bin/sh -e

# This script assumes all source database files are unencrypted
# and assumes sqlite3, ftm-cull-gedcom are already installed

sqlite3 --version
ftm-cull-gedcom --help

srcdir=/srv/arc/virtual_media/windows/shared/ftm

x='
root
Mosher
Disosway
Harrison
Colvin
McLaughlin
Flandreau
Lopez
Lovejoy
Spohner
Taylorson
Justice
Pettit
Romero
'

args=''
for n in $x ; do
    args="$args $srcdir/$n.ftm"
done

ls -l $args

ftm-cull-gedcom $args
