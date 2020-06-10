#!/bin/bash

dirwin=~/dev/local/wingeneal/shared
dirtools=~/dev/github_cmosher01/genealogical-data-private/tools


if [ $# != 1 ] ; then
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



usage: $0 TREE_YYYY-MM-DD-HH-MM-SS

where TREE_YYYY-MM-DD-HH-MM-SS is the name of the tree
(everything from the first "." to the end is ignored)

For example:

$0 Pettit_2018-01-18-19-23-54
EOF
exit 1
fi

me="$(readlink -f "$0")"
here="$(dirname "$me")"

usrarg="${1%%.*}"
echo "using: $usrarg"
tre="${usrarg}"
tre="${tre%_*}"
tre="${tre,,}"

gedloc="$(readlink -f "$tre.ged")"
if [ ! -r "$gedloc" ] ; then
    echo "Cannot find $gedloc" >&2
    exit 1
fi

gedftm="$(readlink -f "$dirwin/$usrarg.ftm.ged")"
if [ ! -r "$gedftm" ] ; then
    echo "Cannot find $gedftm" >&2
    exit 1
fi

echo "$here/get_apid_from_anc_ftm.sh \\"
echo "    $gedloc \\"
echo "    $gedftm \\"
echo "    $dirtools/subm.ged"

$here/get_apid_from_anc_ftm.sh $gedloc $gedftm $dirtools/subm.ged
