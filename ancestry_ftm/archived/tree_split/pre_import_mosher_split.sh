#!/bin/bash

cd ~/docker/geneal/work/201709_mosher_split/

repo=~/dev/github_cmosher01/genealogical-data

for i in * ; do
    cd $i
    echo "========================"
    echo "$i..."
    ~/dev/github_cmosher01/Gedcom-Misc/ancestry_ftm/pre_import.sh -f <$repo/$i.ged >$i.import.ged
    mv -v orig.ged $repo/$i.ged
    mv -v $i.import.ged ~/dev/local/wingeneal/shared/mosher_split_KEEP/
    cd - >/dev/null
done
