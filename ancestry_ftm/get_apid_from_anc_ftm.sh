#!/bin/sh

if [ ! -r "$1" -o ! -r "$2" ] ; then
    echo "usage: $0 orig.ged ftm.export.ged subm.ged" >&2
    echo "Process a GEDCOM file exported from FTM." >&2
    exit 1
fi

me="$(readlink -f "$0")"
here="$(dirname "$me")"
orig_ged="$(readlink -f "$1")"
ftm_ged="$(readlink -f "$2")"
subm_ged="$(readlink -f "$3")"

t=$(mktemp -d)
cd $t

echo "FTM-UPDATE: Intermediate files and reports in: $(pwd)" >&2



echo "FTM-UPDATE: Begin processing original file..." >&2

cp -v "$orig_ged" ./original.ged

cat <original.ged | \
gedcom-sort -c 60 | \
cat >original.std.ged



echo "FTM-UPDATE: Begin processing FTM file..." >&2

cp -v "$ftm_ged" ./ftm.ged

# TODO inline post_export here

$here/post_export.sh original.std.ged ftm.ged |
gedcom-restorehead -c 60 -g $subm_ged | \
gedcom-sort -c 60 -s | \
cat >matched.ged


echo "FTM-UPDATE: Checking for suspicious citation lengths (possibly truncated)..." >&2
gedcom-check-len -c 60 -w .INDI.\*.SOUR.PAGE <matched.ged >&2
echo "FTM-UPDATE: Checking for _APIDs with multiple sources (which have the potential to be merged)..." >&2
gedcom-check-dups -c 60 -w .SOUR._APID <matched.ged >&2
echo "FTM-UPDATE: Checking for INDIs with same REFN..." >&2
gedcom-check-dups -c 60 -w .INDI.REFN <matched.ged >&2
echo "FTM-UPDATE: Checking for duplicate media references..." >&2
gedcom-check-dups -c 60 -w .OBJE.FILE <matched.ged >&2
echo "FTM-UPDATE: Checking general parsability of GEDCOM file..." >&2
gedcom-lib --model <matched.ged >/dev/null



echo "FTM-UPDATE: Copying GEDCOM file to current directory..." >&2
cp -v $(pwd)/matched.ged $orig_ged



echo "FTM-UPDATE: Intermediate files and reports in: $(pwd)" >&2
