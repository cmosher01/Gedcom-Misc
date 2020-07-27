#!/bin/bash

cd ~/docker/geneal/work/201709_mosher_split/

for i in * ; do
    cd $i
    ~/dev/github_cmosher01/Gedcom-Misc/ancestry_ftm/extract_gedcom.sh ~/docker/geneal/mosher.ged
    cd -
done
