#!/bin/sh

if [ ! -r "$1" -o ! -r "$2" ] ; then
    echo "usage: $0 orig.ged anc.export.ged" >&2
    echo "Process a GEDCOM file exported from Ancestry." >&2
    echo "Tries to add _APIDs from anc.export.ged back to" >&2
    echo "orig.ged file, which is assumed similar." >&2
    exit 1
fi

orig_ged="$(readlink -f "$1")"
ancs_ged="$(readlink -f "$2")"

t=$(mktemp -d)
cd $t
echo "Intermediate files and reports in: $(pwd)"



echo "Fixing original file: $orig_ged"
cp "$orig_ged" ./original.ged
cat original.ged | \
gedcom-lib -c 60 -u -s | \
gedcom-sort -c 60 | \
cat >original.std.ged

echo "Fixing Ancestry.com file: $ancs_ged"
gedcom-fixancestryexport UTF8 <"$ancs_ged" >ancestry.ged

cat ancestry.ged | \
gedcom-uid | \
gedcom-lib -c 60 -u -s | \
gedcom-fixdate -c 60 | \
gedcom-tagfromnote -c 60 -x _UID -n REFN | \
# gedcom-unnote -c 60 -d | \
# gedcom-unnote -c 60 -n inline | \
gedcom-eventize -c 60 -w '.INDI._MILT' -t military | \
gedcom-restoreids -c 60 -g original.std.ged \
    -w '.REPO.NAME' \
    -w '.*.REFN' \
    -w '.INDI.NAME' \
    -w '.INDI.BIRT.DATE' \
    -w '.INDI.DEAT.DATE' \
    -w '.SOUR.TITL' \
    | \
gedcom-restoreids -c 60 -g original.std.ged \
    -w '.FAM.HUSB' \
    -w '.FAM.WIFE' \
    | \
gedcom-sort -c 60 | \
cat >ancestry.fix.ged



gedcom-matchapid -c 60 -a -g ancestry.fix.ged <original.std.ged 2>matched.log | \
gedcom-sort -c 60 | \
cat >matched.ged


diff -d -u -F '^0 ' ./original.std.ged ./matched.ged >matched.diff



# find lost _APIDs
grep ' _APID ' ancestry.fix.ged | grep -v '::0$' | cut -d ' ' -f 3 | LC_ALL=c sort -u >ancestry.uniq.apid
grep ' _APID '      matched.ged | grep -v '::0$' | cut -d ' ' -f 3 | LC_ALL=c sort -u >matched.uniq.apid
diff -d -u0 ancestry.uniq.apid matched.uniq.apid >lost.apid.diff



echo "Intermediate files and reports in: $(pwd)"
