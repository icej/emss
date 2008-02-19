#!/usr/bin/python
import os
for i in range(2):
   print "erl -noshell -s aclient start %(i)s %(i)s > %(i)sa.log &"%{'i':i}
   os.popen("erl -noshell -s aclient start %(i)s %(i)s > %(i)sa.log &"%{'i':i})

