#!/bin/sh

if [ "$1" != "-f" ] ; then
    echo "usage: $0 -f <in.ged >out.ged" >&2
    echo "Prepares a GEDCOM file for import into FTM." >&2
    exit 1
fi



j="java -jar $HOME/dev/github_cmosher01"

g_refn="$j/Gedcom-Refn/build/libs/gedcom-refn-1.0.0-SNAPSHOT-all.jar"
g_noty="$j/Gedcom-Notary/build/libs/gedcom-notary-1.0.0-SNAPSHOT-all.jar"
g_sort="$j/Gedcom-Sort/build/libs/gedcom-sort-1.0.0-SNAPSHOT-all.jar"
g_unot="$j/Gedcom-UnNote/build/libs/gedcom-unnote-1.0.0-SNAPSHOT-all.jar"
g_ed="$j/Gedcom-Ed/build/libs/gedcom-ed-1.0.0-SNAPSHOT-all.jar"


$g_unot -c 60 -d | \
$g_unot -c 60 -n inline | \
$g_refn | \
$g_ed -c 60 -w '.HEAD.SOUR' --update=FTM -R | \
$g_sort -c 60 -s -u | tee orig.ged | \
$g_noty -c 60 -w '.INDI.*.DATE"[^0-9].*"' -i sibling | \
$g_noty -c 60 -w '.SOUR.TEXT' -i sibling -d | \
$g_noty -c 60 -w '.OBJE.REFN' -i sibling -d | \
$g_noty -c 60 -w '.SOUR.REFN' -i sibling -d

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
