#!/bin/sh -xe

# When you first decrypt a *.ftm file created by Family Tree Maker, it cannot be
# opened by SQLite. The file contains an invalid byte in the SQLite header
# area: see https://www.sqlite.org/fileformat.html "Maximum embedded payload fraction. Must be 64."
# Fixing up this byte from 32 to 64 fixes the problem.

# For a copy of the FTM directory (containing unencrypted *.ftm files):
# * fixup 0x20 -> 0x40

# This script assumes all source database files are unencrypted
# and assumes sqlite3 is already installed

sqlite3 --version

#srcdir=~/dev/local/wingeneal/shared/FTM_DOCUMENTS
srcdir=/srv/arc/virtual_media/windows/shared/ftm/

offset=21
patch=@

cd $srcdir
for db in *.ftm ; do
    existing="$(dd if="$db" bs=1 skip=$offset count=1)"
    if [ "$patch" != "$existing" ] ; then
        echo "patching from '$existing' to '$patch'"
        printf "%c" "$patch" | dd bs=1 seek=$offset conv=notrunc of="$db"
    else
        echo "no patch required: '$existing' = '$patch'"
    fi
done
pwd
ls -lht --full-time --color
cd -
