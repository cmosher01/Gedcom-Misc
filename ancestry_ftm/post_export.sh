#!/bin/sh

if [ ! -r "$1" -o ! -r "$2" ] ; then
    echo "usage: $0 orig.ged ftm.export.ged >out.ged" >&2
    echo "Process a GEDCOM file exported from FTM." >&2
    echo "It is assumed the GEDCOM file was processed with" >&2
    echo "pre_import.sh before importing into FTM." >&2
    exit 1
fi

# hack to restore SUBM ID (assumes only one per file)
subm=$(grep '^0 @.*@ SUBM' "$1" | cut -d' ' -f2)

dos2unix "$2"
cat "$2" | \
# gedcom-fixancestryexport UTF8 | \    Uncomment for Ancestry export
gedcom-notary -c 60 -w '.INDI.*.NOTE' -x sibling -d | \
gedcom-notary -c 60 -w '.SOUR.NOTE' -x sibling | \
gedcom-notary -c 60 -w '.OBJE.NOTE' -x sibling | \
gedcom-unnote -c 60 -d | \
gedcom-unnote -c 60 -n inline | \
gedcom-unftmevent -t _XY | \
gedcom-restoreids -c 60 -g "$1" -w '.REPO.NAME' -w '.*.REFN' | \
gedcom-sort -c 60 -s -u | \
sed -e "s/ SUBM @.*@/ SUBM $subm/" -e "s/0 @.*@ SUBM/0 $subm SUBM/"
