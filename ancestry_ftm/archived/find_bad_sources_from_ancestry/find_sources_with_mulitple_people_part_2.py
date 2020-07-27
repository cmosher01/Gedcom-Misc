import sys

previd = ''
prevline = ''
for line in sys.stdin:
    attrs = line.strip().split(' ', 1)

    id = attrs[0]
    if id == previd:
        print prevline.strip()
        print line.strip()
    previd = id
    prevline = line
