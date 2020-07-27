#!/bin/sh -e

# This script was for my 2017-08 merging from Ancestry.com exported Gedcom
# back into my originla GEDCOM files.

show_help() {
    echo "usage: $0 [-fv] ancestry.ged original.ged" >&2
}

verbose=false
force=false
OPTIND=1
while getopts "\?hvf" opt ; do
    case "$opt" in
        h|\?) show_help ; exit 0 ;;
        v) verbose=true ;;
        f) force=true ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

if [ $# -ne 2 ] ; then
    show_help
    exit 1
fi
ancs_ged="$(readlink -f "$1")"
orig_ged="$(readlink -f "$2")"



t=$(mktemp -d)
cd $t
if $verbose ; then
    echo "Intermediate files and reports in: $(pwd)"
fi


if $verbose ; then
    echo "Fixing original file: $orig_ged"
fi
cp "$orig_ged" ./original.ged
gedcom-fixer original.ged >original.fix.ged 2>original.report
# also creates original.ged.ids

if $verbose ; then
    echo "Fixing Ancestry.com file: $ancs_ged"
fi
get=cp
if $force ; then
    get=mv
fi
$get "$ancs_ged" ./ancestry.ged
gedcom-uid <ancestry.ged >ancestry.uid.ged
gedcom-fixer ancestry.uid.ged original.ged.ids >ancestry.fix.ged 2>ancestry.report
# also creates (useless) ancestry.uid.ged.ids



if $verbose ; then
    echo "Attempting to match files..."
fi
gedcom-matcher original.fix.ged ancestry.fix.ged >matched.ged 2>match.report
gedcom-fixer matched.ged >matched.fix.ged 2>fix.matched.report
diff -d -u -F '^0 ' ./original.fix.ged ./matched.fix.ged >match.diff || true

echo '----------' >reports.txt
echo "original.report" >>reports.txt
cat original.report | grep -v 'Cannot find REFN' >>reports.txt || true
echo '----------' >>reports.txt
echo "ancestry.report" >>reports.txt
cat ancestry.report | grep -v 'Cannot find REFN' >>reports.txt || true
echo '----------' >>reports.txt
echo "match.report" >>reports.txt
cat match.report | grep -v ' checking' | grep -v 'Cannot find REFN' >>reports.txt || true
echo '----------' >>reports.txt
echo "fix.matched.report" >>reports.txt
cat fix.matched.report | grep -v 'Cannot find REFN' >>reports.txt || true

if command -v gramps ; then
    echo '----------' >>reports.txt
    echo "gramps verify:" >>reports.txt
    gramps -q -i matched.fix.ged -a tool -p name=verify >>reports.txt 2>&1
fi

if $force ; then
    cp matched.fix.ged "$orig_ged"
    echo "TO SAVE REPORTS: cp -v reports.txt TARGET/"
fi
