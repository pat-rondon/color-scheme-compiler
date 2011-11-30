#!/usr/bin/env python

# convert namedColors.ml to use hex colors instead of int triples

import sys, re

p = '("[^"]*"),\s*\(([0-9]*),\s*([0-9]*),\s*([0-9]*)\)'

for l in open('namedColors.ml'):
  l = l.strip()
  m = re.search(p, l)
  if m == None:
    print "FAIL: %s" % l
    sys.exit(1)
  else:
    print '  ; %-25s, "#%02X%02X%02X"' % \
      ( m.group(1)
      , int(m.group(2))
      , int(m.group(3))
      , int(m.group(4))
      )

