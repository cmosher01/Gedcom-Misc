#!/bin/sh -xe

# For a copy of the FTM directory (containing unencrypted *.ftm files):
# * fixup 0x20 -> 0x40

# This script assumes all source database files are unencrypted
# and assumes sqlite3 is already installed

sqlite3 --version

srcdir=~/dev/local/wingeneal/shared/FTM_DOCUMENTS

offset=21
patch=@

cd $srcdir
for db in *.ftm ; do
    existing="`dd if="$db" bs=1 skip=$offset count=1`"
    if [ "$patch" != "$existing" ] ; then
        echo "patching from '$existing' to '$patch'"
        printf "$patch" | dd bs=1 seek=$offset conv=notrunc of="$db"
    else
        echo "no patch required: '$existing' = '$patch'"
    fi
done
pwd
ls -lht --full-time --color
cd -
