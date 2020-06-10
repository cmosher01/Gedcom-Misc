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
subm_ged="$(readlink -f "$4")"

t=$(mktemp -d)
cd $t

echo "Intermediate files and reports in: $(pwd)"
echo "Launching Sublime Edit to open that directory..."
subl $(pwd)



cp "$orig_ged" ./original.ged

cat <original.ged | \
gedcom-lib -c 60 -u | \
gedcom-sort -c 60 | \
cat >original.std.ged



cp "$ftm_ged" ./ftm.ged

$here/post_export.sh original.std.ged ftm.ged |
gedcom-unnote -c 60 -d | \
gedcom-unnote -c 60 -n inline | \
gedcom-note-gc | \
gedcom-restorehead -c 60 -g $subm_ged | \
gedcom-sort -c 60 -s | \
cat >matched.ged



diff -d -u -F '^0 ' ./original.ged ./matched.ged >matched.diff



echo "Intermediate files and reports in: $(pwd)"
read -r -p 'Check the log and diff files now. Are the changes acceptable? (y,n) <N> ' response
if [ "$response" = "y" ] ; then
    cp $(pwd)/matched.ged $orig_ged
fi
