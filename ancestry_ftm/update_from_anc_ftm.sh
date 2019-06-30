#!/bin/bash

dirwin=~/dev/local/wingeneal/shared
dirtools=~/dev/github_cmosher01/genealogical-data/tools


if [ $# != 1 ] ; then
cat - >&2 <<EOF

Top-level shell script to update local GEDCOM file
with changes from an FTM export, adding citation
references (_APID records) from the syncronized
Ancestry.com export.

Assumes the original version of the GEDCOM file
is in the current directory.

Pulls the changed GEDCOM file, exported from FTM, from
$dirwin

Exports the corresponding GEDCOM file from Ancestry.com
assuming it has been syncronized.

The file names are determined from the single input
parameter as follows:

given parameter:        TREE_YYYY-MM-DD-HH-MM-SS
original file:          ./TREE.ged
FTM export:             $dirwin/TREE_YYYY-MM-DD-HH-MM-SS.ged
Ancstry.com tree name:  TREE

Credentials for logging in to Ancestry.com must be
specified in ~/.ancestry.properties as:

    username=YourAncestryUserName
    password=YourPassword



usage: $0 TREE_YYYY-MM-DD-HH-MM-SS

For example:

$0 Pettit_2018-01-18-19-23-54
EOF
exit 1
fi

me="$(readlink -f "$0")"
here="$(dirname "$me")"

tre="$1"
tre="${tre%_*}"
tre="${tre,,}"

gedloc="$(readlink -f "$tre.ged")"
if [ ! -r "$gedloc" ] ; then
    echo "Cannot find $gedloc" >&2
    exit 1
fi

gedftm="$(readlink -f "$dirwin/$1.ftm.ged")"
if [ ! -r "$gedftm" ] ; then
    echo "Cannot find $gedftm" >&2
    exit 1
fi

$here/get_apid_from_anc_ftm.sh $gedloc $gedftm "$tre" $dirtools/subm.ged
