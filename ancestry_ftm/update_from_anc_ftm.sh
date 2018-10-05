#!/bin/bash

dirgen=~/dev/github_cmosher01/genealogical-data
dirwin=~/dev/local/wingeneal/shared



if [ $# != 1 ] ; then
    echo "usage: $0 Exported_YYYY-MM-DD" >&2
    echo "example:" >&2
    echo "$0 Pettit_2018-01-18-19-23-54" >&2
    exit 1
fi

me="$(readlink -f "$0")"
here="$(dirname "$me")"

tre="$1"
tre="${tre%_*}"
tre="${tre,,}"

cd $dirgen

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

$here/get_apid_from_anc_ftm.sh $gedloc $gedftm "$tre" tools/subm.ged
