#!/bin/sh

if [ ! -r "$1" -o ! -r "$2" ] ; then
    echo "usage: $0 orig.ged ftm.export.ged >out.ged" >&2
    echo "Process a GEDCOM file exported from FTM." >&2
    echo "It is assumed the GEDCOM file was processed with" >&2
    echo "pre_import.sh before importing into FTM." >&2
    exit 1
fi



j="java -jar $HOME/dev/github_cmosher01"

g_noty="$j/Gedcom-Notary/build/libs/gedcom-notary-1.0.0-SNAPSHOT-all.jar"
g_sort="$j/Gedcom-Sort/build/libs/gedcom-sort-1.0.0-SNAPSHOT-all.jar"
g_unot="$j/Gedcom-UnNote/build/libs/gedcom-unnote-1.0.0-SNAPSHOT-all.jar"
g_reid="$j/Gedcom-RestoreIds/build/libs/gedcom-restoreids-1.0.0-SNAPSHOT-all.jar"
g_unev="$j/Gedcom-UnFtmEvent/build/libs/gedcom-unftmevent-1.0.0-SNAPSHOT-all.jar"

# hack to restore SUBM (assumes only one per file)
subm=$(grep '^0 @.*@ SUBM' "$1" | cut -d' ' -f2)

dos2unix "$2"
cat "$2" | \
$g_noty -c 60 -w '.INDI.*.NOTE' -x sibling -d | \
$g_noty -c 60 -w '.SOUR.NOTE' -x sibling | \
$g_noty -c 60 -w '.OBJE.NOTE' -x sibling | \
$g_unot -c 60 -d | \
$g_unot -c 60 -n inline | \
$g_unev -t _XY | \
$g_reid -c 60 -g "$1" -w '.REPO.NAME' -w '.*.REFN' | \
$g_sort -c 60 -s -u | \
sed -e "s/ SUBM @.*@/ SUBM $subm/" -e "s/0 @.*@ SUBM/0 $subm SUBM/"
