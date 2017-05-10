# -*- coding: cp1252 -*-
dateiname = 'dateineu2.txt'
file = open(dateiname,'r')
dok=''
h=0
for line in file:
    if '\n' and ('e' or 'i' or 'a' or 'u' or 'o') in line:
        dok = dok + line
    
    if "==" in line:
        dok = dok + ("\n") 
    
    		
print(dok)
print(h)
file.close
input = raw_input('wie soll die neue datei heissen?  :   ')
file=open(input+".txt",'w')
file.write(dok)
file.close 
