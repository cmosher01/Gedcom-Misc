#!/bin/sh

if [ ! -r "$1" -o ! -r "$2" ] ; then
    echo "usage: $0 orig.ged ftm.export.ged >out.ged" >&2
    echo "Process a GEDCOM file exported from FTM." >&2
    echo "It is assumed the GEDCOM file was processed with" >&2
    echo "pre_import.sh before importing into FTM." >&2
    exit 1
fi

# NOTE: need to add "User information" in FTM (to match NAME in subm.ged file)

echo "FTM-UPDATE: converting text..." >&2
dos2unix -ih "$2" >&2
dos2unix "$2" >&2
dos2unix -ih "$2" >&2

echo "FTM-UPDATE: running pipeline gedcom filters..." >&2
cat "$2" | \
gedcom-notary -c 60 -w '.INDI.*.NOTE' -x sibling -d | \
gedcom-notary -c 60 -w '.SOUR.NOTE' -x sibling | \
gedcom-notary -c 60 -w '.OBJE.NOTE' -x sibling | \
gedcom-unnote -c 60 -d | \
gedcom-unnote -c 60 -n inline | \
gedcom-note-gc | \
gedcom-unftmevent -t _XY | \
gedcom-eventize -c 60 -w '.INDI._EXCM' -t excommunication | \
gedcom-eventize -c 60 -w '.INDI._FUN' -t funeral | \
gedcom-eventize -c 60 -w '.INDI._MILT' -t military | \
gedcom-eventize -c 60 -w '.*.RESI' | \
gedcom-fixdate -c 60 | \
gedcom-restoreids -c 60 -g "$1" -w '.SUBM.NAME' -w '.REPO.NAME' -w '.SOUR.TITL' -w '.*.REFN' -w '.*._GUID' | \
gedcom-fixftmpubl -c 60

# TODO check for place names that don't end with a known country code
# TODO check for unreferenced top-level records (with IDs) (cf. gedcom-note-gc)
# TODO check for families with zero individuals, or with one individual and no events
# TODO for OBJE.FILE, list all directories found (there should be only one directory, the Media directory)

# TODO: add any of these, as necessary
# all custom event types from FTM 2019 (v1252)
# gedcom-eventize -c 60 -w '.*._CIRC' -t 'Circumcision' | \
# gedcom-eventize -c 60 -w '.*._DCAUSE' -t 'Cause of Death' | \
# gedcom-eventize -c 60 -w '.*._DEG' -t 'Degree' | \
# gedcom-eventize -c 60 -w '.*._DEST' -t 'Destination' | \
# gedcom-eventize -c 60 -w '.*._DNA' -t 'DNA Markers' | \
# gedcom-eventize -c 60 -w '.*._ELEC' -t 'Elected' | \
# gedcom-eventize -c 60 -w '.*._EMPLOY' -t 'Employment' | \
# gedcom-eventize -c 60 -w '.*._EXCM' -t 'Excommunication' | \
# gedcom-eventize -c 60 -w '.*._FUN' -t 'Funeral' | \
# gedcom-eventize -c 60 -w '.*._HEIG' -t 'Height' | \
# gedcom-eventize -c 60 -w '.*._INIT' -t 'Initiatory' | \
# gedcom-eventize -c 60 -w '.*._MDCL' -t 'Medical Condition' | \
# gedcom-eventize -c 60 -w '.*._MILT' -t 'Military Service' | \
# gedcom-eventize -c 60 -w '.*._MILTID' -t 'Military Serial Number' | \
# gedcom-eventize -c 60 -w '.*._MISN' -t 'Mission' | \
# gedcom-eventize -c 60 -w '.*._NAMS' -t 'Namesake' | \
# gedcom-eventize -c 60 -w '.*._ORDI' -t 'Ordinance' | \
# gedcom-eventize -c 60 -w '.*._ORIG' -t 'Origin' | \
# gedcom-eventize -c 60 -w '.*._SEPR' -t 'Separation' | \
# gedcom-eventize -c 60 -w '.*._SETT' -t 'Settled' | \
# gedcom-eventize -c 60 -w '.*._WEB' -t 'Web Address' | \
# gedcom-eventize -c 60 -w '.*._WEIG' -t 'Weight' | \
# gedcom-eventize -c 60 -w '.*.ARVL' -t 'Arrival' | \
# gedcom-eventize -c 60 -w '.*.DPRT' -t 'Departure' | \
# gedcom-eventize -c 60 -w '.*.FSID' -t 'FamilySearch ID' | \
# gedcom-eventize -c 60 -w '.*.REFNU' -t 'Relationship ID' | \
#ALSO ???:
# _PHOTO
# _GUID
