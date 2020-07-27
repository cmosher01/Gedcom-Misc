if [ ! "$1" ] ; then
    echo "usage: $0 input.ged" >&2
    exit 1
fi

me="$(readlink -f "$0")"
here="$(dirname "$me")"

grep -E ' _APID |^0 .* INDI|^0 .* FAM|1 NAME|1 HUSB|1 WIFE|1 CHIL' "$1" | \
cut -d' ' -f2- | \
python $here/find_sources_with_mulitple_people.py | \
sort -u | \
python $here/find_sources_with_mulitple_people_part_2.py | \
sort -u
