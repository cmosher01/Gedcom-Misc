#!/bin/sh

if [ ! -r "$1" -o ! -r "$2" ] ; then
    echo "usage: $0 orig.ged ftm.export.ged ancestry-tree-name subm.ged" >&2
    echo "Process a GEDCOM file exported from FTM." >&2
    echo "It is assumed the FTM has already been sync'd with Ancestry.com." >&2
    exit 1
fi

me="$(readlink -f "$0")"
here="$(dirname "$me")"
orig_ged="$(readlink -f "$1")"
ftm_ged="$(readlink -f "$2")"
anc_tree="$3"
subm_ged="$(readlink -f "$4")"

t=$(mktemp -d)
cd $t

echo "Intermediate files and reports in: $(pwd)"
echo "Launching Sublime Edit to open that directory..."
subl $(pwd)



echo "Fixing original file: $orig_ged"
cp "$orig_ged" ./original.ged
cat <original.ged | \
gedcom-lib -c 60 -u | \
gedcom-sort -c 60 | \
cat >original.std.ged



echo "Fixing FTM file: $ftm_ged"
cp "$ftm_ged" ./ftm.ged
$here/post_export.sh original.std.ged ftm.ged >ftm.fix.ged



ancestry-gedcom-download $anc_tree ancestry.bad.ged
echo "Fixing Ancestry.com file"
dos2unix ancestry.bad.ged
cat <ancestry.bad.ged | \
sed 's,<a:unknown>.*</a:unknown>$,,' | \
gedcom-fixancestryexport UTF8 | \
cat >ancestry.ged

cat <ancestry.ged | \
gedcom-uid | \
gedcom-lib -c 60 -u | \
gedcom-fixdate -c 60 | \
gedcom-notary -c 60 -w '.SOUR.NOTE' -x sibling | \
gedcom-tagfromnote -c 60 -x _UID -n REFN | \
gedcom-eventize -c 60 -w '.INDI._EXCM' -t excommunication | \
gedcom-eventize -c 60 -w '.INDI._FUN' -t funeral | \
gedcom-eventize -c 60 -w '.INDI._MILT' -t military | \
gedcom-eventize -c 60 -w '.*.RESI' | \
gedcom-restoreids -c 60 -g ftm.fix.ged \
    -w '.REPO.NAME' \
    -w '.*.REFN' \
    -w '.INDI.NAME' \
    -w '.INDI.BIRT.DATE' \
    -w '.INDI.DEAT.DATE' \
    -w '.SOUR.TITL' \
    | \
gedcom-restoreids -c 60 -g ftm.fix.ged \
    -w '.FAM.HUSB' \
    -w '.FAM.WIFE' \
    | \
gedcom-sort -c 60 | \
cat >ancestry.fix.ged



cat <ftm.fix.ged | \
gedcom-matchapid -c 60 -a -g ancestry.fix.ged 2>matched.log | \
gedcom-unnote -c 60 -d | \
gedcom-unnote -c 60 -n inline | \
gedcom-note-gc | \
gedcom-restorehead -c 60 -g $subm_ged | \
gedcom-sort -c 60 -s | \
cat >matched.ged



diff -d -u -F '^0 ' ./original.ged ./matched.ged >matched.diff



# find lost _APIDs
grep ' _APID ' ancestry.fix.ged | grep -v '::0$' | cut -d ' ' -f 3 | LC_ALL=c sort -u >ancestry.uniq.apid
grep ' _APID '      matched.ged | grep -v '::0$' | cut -d ' ' -f 3 | LC_ALL=c sort -u >matched.uniq.apid
diff -d -u0 ancestry.uniq.apid matched.uniq.apid >lost.apid.diff



echo "Intermediate files and reports in: $(pwd)"
read -r -p 'Check the log and diff files now. Are the changes acceptable? (y,n) <N> ' response
if [ "$response" = "y" ] ; then
    cp $(pwd)/matched.ged $orig_ged
fi
