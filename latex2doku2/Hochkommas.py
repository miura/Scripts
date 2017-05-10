# -*- coding: cp1252 -*-
dateiname = "3"
file = open(dateiname+'.txt','r')
dok = ''
i=0
for line in file:
    i=i+1

for line in file:
    if '\"`' in line:
        line = line.replace('\"`','"')
        print(line)
    if '\"`' in line:
        print('achtung unbekanntes symbol')
        
    if '\"\'' in line:
        line = line.replace('\"\'','"')
        print(line)
    dok = dok + line
print(i)
print(dok)
file2 = open(dateiname+'.txt','w')
file2.write(dok)
file2.close
