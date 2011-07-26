# Batch File proceesing (excel file to csv)
# Kota Miura (miura@embl.de)
# 20110726 first version

# change line 21-24 depending on OS
# and where xls2csv.py is. 
#
# reference 
#   http://groups.google.com/group/python-#   http://groups.google.com/group/python-excel/browse_thread/thread/eb3475b5438c3e50
#   https://github.com/dilshod/xlsx2csv
#   http://blog.codeus.net/reading-xlsx-files-from-python/
# general
#   http://vinayhacks.blogspot.com/2010/04/converting-xls-to-csv-on-linux.html


import xls2csv
import glob
import os
import sys

#mac
sys.path.append('/Users/miura/scripts')
#win
#sys.path.append( 'C:\scripts')

xls_files = glob.glob('*.xls')
if len(xls_files) == 0: 
    raise RuntimeError('No XLS files to convert.')
for file in xls_files:
  try:
    xls2csv.main2( os.path.join(os.getcwd(), file),os.path.join(os.getcwd(), file.split(".xls")[0]+".cvs"))
    break
  except:
    print "!!! unexpected error:", file, sys.exc_info()[0]


