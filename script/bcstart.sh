#!/usr/bin/python
import os
for i in range(2):
   print "erl -noshell -s bclient start \"%(i)s\" \"%(i)s\" > %(i)s.log &"%{'i':i}
   #os.popen("erl -noshell -s bclient start \"%(i)s\" \"%(i)s\"  &"%{'i':i})

