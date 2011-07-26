# Windows Batch File proceesing (excel file to csv)
# Kota Miura (miura@embl.de)
# 20110726 first version
#
# works only with windows with installed MS excel. 
# for OSX and MS win without MS excel, use BatchXls2cvs.py
#
# reference
#   http://gis.utah.gov/code-python/python-convert-ms-excel-to-csv
#   http://groups.google.com/group/python-excel/browse_thread/thread/eb3475b5438c3e50
#   https://github.com/dilshod/xlsx2csv
#   http://blog.codeus.net/reading-xlsx-files-from-python/
# general
#   http://vinayhacks.blogspot.com/2010/04/converting-xls-to-csv-on-linux.html

import glob
import os
import sys
import win32com.client

xls_files = glob.glob('*.xls')
if len(xls_files) == 0: 
    raise RuntimeError('No XLS files to convert.')
excel = win32com.client.Dispatch('Excel.Application')

for file in xls_files:
  try:
    workbook = excel.Workbooks.Open(os.path.join(os.getcwd(), file))
    
  except:
    print "!!! unexpected opening error:", file, sys.exc_info()[0]
  print "Opened: ", file 
  try:
    workbook.SaveAs(os.path.join(os.getcwd(),file.split(".xls")[0]+".csv"), FileFormat=24) # 24 represents xlCSVMSDOS
  except:
    print "!!! saving error occurred"
  workbook.Close(False)  
  print "... closed: ", file
excel.Quit()
del excel
