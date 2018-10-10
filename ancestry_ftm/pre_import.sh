#!/bin/sh

if [ "$1" != "-f" ] ; then
    echo "usage: $0 -f <in.ged >out.ged" >&2
    echo "Prepares a GEDCOM file for import into FTM." >&2
    exit 1
fi

gedcom-unnote -c 60 -d | \
gedcom-unnote -c 60 -n inline | \
gedcom-refn | \
gedcom-sort -c 60 -s -u | \
gedcom-uid -c 60 | \
tee orig.ged | \
gedcom-ed -c 60 -w '.HEAD.SOUR' --update=FTM -R | \
gedcom-notary -c 60 -w '.INDI.*.DATE"[^0-9].*"' -i sibling | \
gedcom-notary -c 60 -w '.SOUR.TEXT' -i sibling -d | \
gedcom-notary -c 60 -w '.OBJE.REFN' -i sibling -d | \
gedcom-notary -c 60 -w '.SOUR.REFN' -i sibling -d

# Remaining differences:
# ----------------------
# loses entire SUBM record
# loses all RIN records
# loses all _APID records
# removes leading zeroes on dates
# adds .FAM.CHIL._FREL and .FAM.CHIL._MREL
# .OBJE.FILE for ancestry links goes away
#     (but it's OK, it keeps local media copy)
# removes some dup SOUR citations (good)
# FTM/Ancestry tries to fieldize PUBL with
#     Name, Location, and Date:
#     "Name: nnn; Location: lll; Date: ddd;"
# Sync w/Ancestry truncates PAGE (source citation detail) at 256 characters
