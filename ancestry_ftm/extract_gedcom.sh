#!/bin/sh -e

# param: input gedcom file
# uses current directory name to look for input file.xy,
# and to name the output files

# The input file.xy file is a list of X Y coordinates of
# INDIs from mosher.ged, obtained by opening the mosher.ged
# file in Genealogy Research Organizer, selecing the people to
# export, and then copying (to the clipboard).

i="$(readlink -f "$1")"
if [ ! -r "$i" ] ; then
    echo "$0: ERROR: cannot read file $1" >&2
    echo " " >&2
    echo "usage: $0 input.ged" >&2
    exit 1
fi

n="$(basename $(readlink -f ./))"
if [ ! -r $n.xy ] ; then
    echo "$0: ERROR: cannot read file $n.xy" >&2
    exit 1
fi

gedcom-select -g $i -w '.INDI._XY' <$n.xy | \
gedcom-pointees -g $i -f $n.skel.ids | \
gedcom-extract -g $i -f $n.skel.ids >$n.ged

gramps -q -i $n.ged -a tool -p name=verify >$n.gramps.verify 2>&1
