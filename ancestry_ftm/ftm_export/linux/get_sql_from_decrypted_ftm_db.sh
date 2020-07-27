#!/bin/sh -xe

# first exit FTM on windows (to make sure tree files are closed)
# then run decrypt_ftm_files.bat on windows
# then run this script
#
# assumes sqlite3 is installed here

sqlite3 --version

srcdir=~/dev/local/wingeneal/shared/ftm_decrypted
bakdir=/srv/arc/geneal/backups/family_tree_maker

ts=$(date +%Y%m%d_%H%M%S)

cd $srcdir

for db in *.db ; do
    sqlite3 "$db" "update MediaFile set Thumbnail = null;"
    sqlite3 "$db" ".selftest --init"

    echo "/*" >"${db}.sql"
    echo "backup timestamp: $ts" >>"${db}.sql"
    sqlite3 "$db" .databases .tables .dbinfo >>"${db}.sql"
    echo "*/" >>"${db}.sql"
    sqlite3 "$db" .dump >>"${db}.sql"
done

dos2unix -ih *.sql
dos2unix *.sql
dos2unix -ih *.sql

tar czvf $ts-ftm_sql.tar.gz *.sql
tar czvf $ts-ftm_db.tar.gz *.db
tar czvf $ts-ftm_ftm.tar.gz *.ftm

ls -lh

cp -v *.gz $bakdir/

cd -
