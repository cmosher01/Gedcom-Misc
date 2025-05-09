#!/bin/sh -e

# This script assumes all source database files are unencrypted
# and assumes sqlite3,dos2unix,rsync are already installed



# RECOMMENDED PROCESS
# Patch FTM to work exclusively with unencrypted files.
# Use Windows in a VM to update FTM files in the current directory, a shared directory between Windows and this host
# Make any changes
# synchronize with Ancestry.com
# QUIT THE WINDOWS VM
# Manually examine the shared directory for foul play (e.g., ransomware)
# Run this script, which first runs a sanity check on the *.ftm files, and aborts if any are corrupt
# If all *.ftm files are readable, this script make an rsync copy to bakdir (define below), and
# extracts text SQL files of each tree and copies it to the gitdir (define below)

# MAKE SURE bakdir is not reachable by (i.e., shared with) the Windows VM



bakdir=/srv/arc/linode/backup/ftm
dstdir=/srv/arc/linode/ftm
gitdir=/srv/arc/dev/github_cmosher01/family-tree-maker-data

cull_files='
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








sqlite3 --version
dos2unix --version
rsync --version
ftm-fixer --version
ftm-cull-gedcom --help



srcdir=$(pwd)



# make sure there is at least one *.ftm file
bf=$((0))
for f in *.ftm ; do
  if [ -e "$f" ] ; then
    bf=$((bf+1))
  fi
done
if [ $((bf)) -eq 0 ] ; then
  echo "No *.ftm files found in $srcdir"
  exit 1
fi
# go through all *.ftm files and do a sanity check to be sure they are actually SQLite databases
find . -maxdepth 1 -name \*.ftm -print0 | xargs -0 -I {} sqlite3 {} .databases \;
cd -
echo "============================================================="



# full mirror backup
mkdir -p $bakdir
rsync -ltvihPr $srcdir/ $bakdir/
echo "============================================================="



# Java program to check and fix various things
ftm-fixer --force $srcdir/*.ftm
echo "============================================================="



# deploy (fixed version) to staging directory
mkdir -p $dstdir
rsync -ltvihPr $srcdir/ $dstdir/



# make .sql files (in temp work area) and copy to gitdir
tmpdir=$(mktemp -d)
rsync -ltvihPr --include='*.ftm' --exclude='*' $srcdir/ $tmpdir/
cd $tmpdir
for db in *.ftm ; do
    sqlite3 "${db}" "UPDATE MediaFile SET Thumbnail = NULL;"
    sqlite3 "${db}" ".selftest --init"
    # to verify later run:
    # sqlite> .selftest
    # Tests generated by --init
    # 0 errors out of 49 tests

    {
        echo "/*"
        sqlite3 "${db}" .tables
        echo "*/"
        sqlite3 "${db}" .dump | sed 's/localized_caseinsensitive/NOCASE/'
    } >"${db}.sql"

    dos2unix "${db}.sql"
    dos2unix -ih "${db}.sql"

    cp -v "${db}.sql" "${gitdir}/"
done
echo "============================================================="
cd -



# make culled GEDCOM file, leave in temp dir
# this file should be uploaded to Ancestry for the DNA tree
cd $tmpdir
args=''
for n in $cull_files ; do
    args="$args $n.ftm"
done
ftm-cull-gedcom $args
echo "============================================================="
cd -



echo "tmp   : $tmpdir"
echo "from  : $srcdir"
echo "to    : $dstdir"
echo "backup: $bakdir"
echo "SQL   : $gitdir"
