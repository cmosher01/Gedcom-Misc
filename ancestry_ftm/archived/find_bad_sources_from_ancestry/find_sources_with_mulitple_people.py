import sys
import collections

id = ''
name = ''
apids = []
famids = []
map_id_name = {}
map_apid_ids = collections.defaultdict(set)
ok_ids = collections.defaultdict(set)
for line in sys.stdin:
    attrs = line.strip().split(' ', 1)

    tag = attrs[0]
    if tag == 'NAME':
        name = attrs[1]
    elif tag == '_APID':
        apids.append(attrs[1])
    elif tag == 'HUSB' or tag == 'WIFE' or tag == 'CHIL':
        famids.append(attrs[1])
    elif tag.startswith('@'):
        if apids:
            if name:
                map_id_name[id] = name
            if famids:
                for apid in apids:
                    for famid in famids:
                        ok_ids[apid].add(famid)
            else:
                for apid in apids:
                    map_apid_ids[apid].add(id)
        id = tag
        name = ''
        apids = []
        famids = []
    else:
        print 'ERROR: unexpected line: {}'.format(line)

for apid, ids in map_apid_ids.items():
    for id in ids:
        if id not in ok_ids[apid]:
            print apid, id, map_id_name[id]
