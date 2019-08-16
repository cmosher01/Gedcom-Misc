#!/bin/bash

me="$(perl -MCwd -e 'print Cwd::abs_path shift' "$0")"
here="$(dirname "$me")"

cd here

t=$(mktemp -d)
cd $t
echo "All output will be in this directory: $(pwd)"
echo "Launching Sublime Edit to open that directory..."
subl $(pwd)

gedcom-uid <$here/../genealogical-data-private/root.ged >root.ged
gedcom-cull root.ged
gedcom-attach master.ged root.ged.cull

for ged in mosher lovejoy colvin spohner harrison taylorson mclaughlin disosway justice flandreau pettit lopez romero ; do
    gedcom-uid <$here/../genealogical-data/$ged.ged >$ged.ged
    gedcom-cull $ged.ged
    gedcom-attach master.ged master.ged $ged.ged.cull
done
