#!/bin/sh

if [ $# != 2 ] ; then
    echo "usage: $0 local Exported_YYYY" >&2
    echo "example:" >&2
    echo "$0 pettit Pettit_2018-01-18-19-23-54" >&2
    exit 1
fi

me="$(readlink -f "$0")"
here="$(dirname "$me")"
dirgen=~/dev/github_cmosher01/genealogical-data
dirwin=~/dev/local/wingeneal/shared

cd $dirgen

gedloc="$(readlink -f "$1.ged")"
if [ ! -r "$gedloc" ] ; then
    echo "Cannot find $gedLoc" >&2
    exit 1
fi

gedftm="$(readlink -f "$dirwin/$2.ftm.ged")"
if [ ! -r "$gedftm" ] ; then
    echo "Cannot find $gedftm" >&2
    exit 1
fi

gedanc="$(readlink -f "$dirwin/$2.anc.ged")"
if [ ! -r "$gedanc" ] ; then
    echo "Cannot find $gedanc" >&2
    exit 1
fi

$here/get_apid_from_anc_ftm.sh $gedloc $gedftm $gedanc tools/subm.ged

