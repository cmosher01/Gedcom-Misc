#!/bin/bash -e

dirwin=~/dev/local/wingeneal/shared
dirtools=~/dev/github_cmosher01/genealogical-data-private/tools


if [ "$1" = "-h" -o "$1" = "--help" ] ; then
cat - >&2 <<EOF

Top-level shell script to update local GEDCOM file
(in the CURRENT DIRECTORY)
with changes from an FTM export.

Pulls the changed GEDCOM file, exported from FTM, from
$dirwin

The file names are determined from the single input
parameter as follows:

    given parameter:        TREE_YYYY-MM-DD-HH-MM-SS
    original file:          ./TREE.ged
    FTM export:             $dirwin/TREE_YYYY-MM-DD-HH-MM-SS.ged

If no parameter is given, then it defaults to using the latest file.

usage: $0 [ TREE_YYYY-MM-DD-HH-MM-SS ]

where TREE_YYYY-MM-DD-HH-MM-SS is the name of the tree
(everything from the first "." to the end is ignored)

For example:

$0 Pettit_2018-01-18-19-23-54
EOF
exit 1
fi

me="$(readlink -f "$0")"
here="$(dirname "$me")"



if [ -z "$1" ] ; then
    usrarg="$(ls -tp "$dirwin" | grep -v /$ | head -1)"
    echo "$(date -uIns)  latest file:  $usrarg"
    read -r -p "$(date -uIns)  OK to use that file? (y,n) <Y> " response
    if [ "$response" != "y" -a "$response" != "Y" -a "$response" != "" ] ; then
        exit 1
    fi
    usrarg="${usrarg%%.*}"
else
    usrarg="${1%%.*}"
fi



echo "using: $usrarg"
tre="${usrarg}"
tre="${tre%_*}"
tre="${tre,,}"

gedloc="$(readlink -f "$tre.ged")"
if [ ! -r "$gedloc" ] ; then
    echo "FTM-UPDATE: Cannot find $gedloc" >&2
    exit 1
fi

gedftm="$(readlink -f "$dirwin/$usrarg.ftm.ged")"
if [ ! -r "$gedftm" ] ; then
    echo "FTM-UPDATE: Cannot find $gedftm" >&2
    exit 1
fi

echo "$here/get_apid_from_anc_ftm.sh \\"
echo "    $gedloc \\"
echo "    $gedftm \\"
echo "    $dirtools/subm.ged" >&2

$here/get_apid_from_anc_ftm.sh $gedloc $gedftm $dirtools/subm.ged

# TODO accum all output messages into log file
