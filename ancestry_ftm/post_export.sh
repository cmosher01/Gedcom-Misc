#!/bin/sh

if [ ! -r "$1" -o ! -r "$2" ] ; then
    echo "usage: $0 orig.ged ftm.export.ged >out.ged" >&2
    echo "Process a GEDCOM file exported from FTM." >&2
    echo "It is assumed the GEDCOM file was processed with" >&2
    echo "pre_import.sh before importing into FTM." >&2
    exit 1
fi

# hack to restore SUBM ID (assumes only one per file)
echo "FTM-UPDATE: getting SUBM..." >&2
subm=$(grep '^0 @.*@ SUBM' "$1" | cut -d' ' -f2)

echo "FTM-UPDATE: converting text..." >&2
dos2unix "$2"

echo "FTM-UPDATE: running pipeline gedcom filters..." >&2
cat "$2" | \
gedcom-notary -c 60 -w '.INDI.*.NOTE' -x sibling -d | \
gedcom-notary -c 60 -w '.SOUR.NOTE' -x sibling | \
gedcom-notary -c 60 -w '.OBJE.NOTE' -x sibling | \
gedcom-unnote -c 60 -d | \
gedcom-unnote -c 60 -n inline | \
gedcom-unftmevent -t _XY | \
gedcom-eventize -c 60 -w '.INDI._EXCM' -t excommunication | \
gedcom-eventize -c 60 -w '.INDI._FUN' -t funeral | \
gedcom-eventize -c 60 -w '.INDI._MILT' -t military | \
gedcom-eventize -c 60 -w '.*.RESI' | \
gedcom-fixdate -c 60 | \
gedcom-restoreids -c 60 -g "$1" -w '.REPO.NAME' -w '.SOUR.TITL' -w '.*.REFN' -w '.*._GUID' | \
gedcom-fixftmpubl -c 60 | \
gedcom-sort -c 60 -u | \
sed -e "s/ SUBM @.*@/ SUBM $subm/" -e "s/0 @.*@ SUBM/0 $subm SUBM/"
