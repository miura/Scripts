# -*- coding: cp1252 -*-

# dieses Skript dient dazu um Leerzeilen in einem Latex Dokument zu entfernen 
# dazu wird geprüft ob in einer Zeile ein \n und noch andere Buchstaben stehen,  
# wenn keine anderen Buchstaben stehen wird die Zeile entfernt.

dateiname = raw_input(' Bitte Dateinamen eingeben!:  ')
dateiname2= raw_input(' Wie soll die neue Datei heissen?   ')
file = open(dateiname + ".tex",'r')
dok =''
i=0
j=0
a=0

for line in file:
    i=i+1
    if '\n' and ('e' or 'i' or 'a' or 'u' or 'o') in line:
        print(line.strip())
        line = line.strip()
        dok = dok +'\n' + line

    
print('es wurden ', i ,' Zeilen entfernt ')
file.close

# Das doppelte speichern dient dazu um eventuell auftrettende fehler wie 
# es wird nur ein gewisser teil von "dok" eingeschrieben oder die datei 
# existiert noch nciht und muss erst erstellt werden, dabei traten bei mir häufig fehler auf 
# die sich auf diese art beheben liesen 

file1=open(dateiname2,'w')
file1.write(dok)
file1.close
file1=open(dateiname2,'w')
file1.write(dok)
file1.close

