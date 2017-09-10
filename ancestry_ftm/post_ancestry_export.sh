#!/bin/sh

if [ ! -r "$1" -o ! -r "$2" ] ; then
    echo "usage: $0 orig.ged anc.export.ged >out.ged" >&2
    echo "Process a GEDCOM file exported from Ancestry." >&2
    echo "It is assumed the GEDCOM file was processed with" >&2
    echo "pre_import.sh before importing into FTM and synching." >&2
    echo "synching with Ancestry.com." >&2
    exit 1
fi



j="java -jar $HOME/dev/github_cmosher01"

g_fixa="$j/Gedcom-FixAncestryExport/build/libs/gedcom-fixancestryexport-1.0.0-SNAPSHOT-all.jar"
g_noty="$j/Gedcom-Notary/build/libs/gedcom-notary-1.0.0-SNAPSHOT-all.jar"
g_sort="$j/Gedcom-Sort/build/libs/gedcom-sort-1.0.0-SNAPSHOT-all.jar"
g_unot="$j/Gedcom-UnNote/build/libs/gedcom-unnote-1.0.0-SNAPSHOT-all.jar"
g_reid="$j/Gedcom-RestoreIds/build/libs/gedcom-restoreids-1.0.0-SNAPSHOT-all.jar"
g_unev="$j/Gedcom-UnFtmEvent/build/libs/gedcom-unftmevent-1.0.0-SNAPSHOT-all.jar"


dos2unix "$2"
cat "$2" | \
$g_fixa UTF-8 | \
$g_noty -c 60 -w '.INDI.*.NOTE' -x sibling -d | \
$g_noty -c 60 -w '.SOUR.NOTE' -x sibling | \
$g_noty -c 60 -w '.OBJE.NOTE' -x sibling | \
$g_unot -c 60 -d | \
$g_unot -c 60 -n inline | \
$g_unev -t _XY | \
$g_reid -c 60 -g "$1" -w '.REPO.NAME' -w '.*.REFN' -w '.INDI.NAME' | \
$g_sort -c 60 -s -u

# There are a ton more differences, but I don't need
# to try to fix all of them. All we need out of here
# is the _APID rows (which only appear as '.INDI.*.SOUR._APID'
# apparently).
# The events can be matched on type, DATE, and SOUR (using SOUR>REFN)
