#!/bin/sh -xe

# This script assumes all source database files are unencrypted
# and assumes sqlite3 is already installed

sqlite3 --version

srcdir=~/dev/local/wingeneal/shared/FTM_DOCUMENTS

ts=$(date +%Y%m%d_%H%M%S)
bakdir=/srv/arc/geneal/backups/family_tree_maker/$ts
mkdir $bakdir


cd $srcdir
for db in *.ftm ; do
    cp "${db}" "$bakdir/${db}.db"
done
cd -



cd $bakdir

for db in *.db ; do
    sqlite3 "${db}" "update MediaFile set Thumbnail = null;"
    sqlite3 "${db}" ".selftest --init"

    echo "/*" >"${db}.sql"
    echo "backup timestamp: $ts" >>"${db}.sql"
    sqlite3 "${db}" .databases .tables .dbinfo >>"${db}.sql"
    echo "*/" >>"${db}.sql"
    sqlite3 "${db}" .dump >>"${db}.sql"
done

dos2unix -ih *.sql
dos2unix *.sql
dos2unix -ih *.sql

tar czvf ${ts}.nothumb.ftm.sqlite3db.sql.tar.gz *.sql
tar czvf ${ts}.nothumb.ftm.sqlite3db.tar.gz *.db

rm *.db *.sql

ls -lh --color

cd -
