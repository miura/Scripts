# -*- coding: cp1252 -*-
name = raw_input(' Bitte Dateiname eingeben:  ') # datei auswaehlen
datname=(name+'.tex')                            # dateierweiterung anhängen
file = open(datname,'r')                         # datei oeffnen
file1= open(datname,'r')

# Liste der Latextag's die zu Dokuwiki konvertiert werden soll

befehllatex=['\section{','\subsection{Zweck}','\subsection{Geltungsbereich}','\subsection{ZustÃ¤ndigkeiten}','\subsection{Status}','\subsection{','\subsubsection{','\subsubsubsection{','\subsubsubsubsection{','\\textbf{','\emph{']
befehldoku = [' ====== ','    ?Zweck','    ?Geltungsbereich','    ?Zuständigkeiten','    ?Status',' ===== ',' ==== ',' === ',' == ','**','//',]


delbefehl =['\index{','\label{','\label{sec:']  # Liste der Befehle die ohne ersatz gelöscht werden 

# Variablen definieren
delbefehlindex = 0
ebene=0                                         # Variable für das erstellen von Aufzählungen und Nummerrierungen 
s=[0,0]                                         # Variable für das erstellen von Aufzählungen und Nummerrierungen
xyz =1
z = 0                                           # Zeilenzähler
i = 0
b = 0
posalt = 0                                      # Position des alten befehls 
posklammer = 0                                  # Position der "Klammerzu" 
dok = ''                                        # variable zum Zwischen speichern des neuen Dokumentes
helpline = ''                                   # Hilfsvariable um eine Zeile zwischen zuspeichern

# Beginn Programmcode 

for line in file:                               # Diese Zeilen -->
    i=i+1                                       # machen nixs ausser die Zeilen zu zählen 
 

while i>z:                                      # steuert durch bis alle Zeilen bearbeitet sind 
    for line in file1:                          # für jede zeile im dokument
        b=0

        
# Überprüfung ob Befehle in der Zeile stehen die samt Inhalt entfernt werden sollen 
        
        delbefehlindex = 0                                          # Der Zähler wird zu beginn der Zeile auf null gesetzt
        while delbefehlindex < len(delbefehl):                      # Solange der Zähler kleiner ist als alle befehle die entfallen sollen wird die schleife durchlaufen 
            while delbefehl[delbefehlindex] in line:                # solange der Befehl der an der position von delindex in der liste steht 
                delhelp =''                                         # Die Hilfszeile wird erstellt bzw. geleert
                delindex1 = line.find(delbefehl[delbefehlindex])    # suchen der position des Befehls
                delindex2 = line.find('}')                          # suchen der position der Klammer zu 
                while delindex1>delindex2:                          # solange der befehl hinter der klammer steht""" hallo'} \index{hallo} """ 
                    delhelp = delhelp + line[ :delindex2+1]             # wird die zeile bis zur position der klammer zu +1 abgetrennt und zwischen gespeichert
                    line = line[delindex2+1: ]                          # Zeile wird neu zugewiesen (nur noch der rest nach der klammerzu
                    delindex2 = line.find('}')                          # suchen der Klammer zu in der neuen Zeile 
                    delindex1 = line.find(delbefehl[delbefehlindex])    # suchen des befehls in der neuen Zeile 
                delhelp1 = line[ :delindex1]                        # steht der befehl vor der klammer so wird der bereich vor dem befehl in einen hilfsstring gespeichert 
                delhelp2 =line[delindex2+1: ]                       # und der teil hinter der Klammer wird in einen zweiten hilfstring gespeichert 
                line = delhelp + delhelp1 + delhelp2                # nun wird der eventuell abgetrennte teil vor dem befehl mit den beiden hilfsstrings verbunden ohne den befehl den inhalt des befehls und der klammer zu
            delbefehlindex = delbefehlindex + 1                     # der Zähler wird erhöht um die schleife nochmals zu durchlaufen um weitere befehle in dieser Zeile zu finden 
# Überprüfung abgeschlossen wird bei jeder zeile wiederholt            

# Beginne nach \begin... ( aufzählung und numerierung)  befehlen zu suchen und diese mit hilfe eines schalters zu ersetzen 

#Prüfung

# recht leicht verständlicher Quellcode
# das was nach dem befehl \begin{ steht wird in die liste s eingetragen und bei jedem \item
# wird abgefragt was als letztes in der liste steht und je nach dem wird dann \item ersetzt
# ebene ist eine hilfsvariable die die ebene der verschachtelung mitschreibt. und nur zur überprüfung dient

        if '\\begin{enumerate}' in line:
            s.append(1)
            ebene = ebene + 1
            line = line.replace('\\begin{enumerate}',' ')
        if '\\begin {enumerate}' in line:
            s.append(1)
            ebene = ebene + 1
            line = line.replace('\\begin{enumerate}',' ')
        if '\\begin{itemize}' in line:
            s.append(2)
            ebene = ebene + 1
            line = line.replace('\\begin{itemize}',' ')
        if '\\begin {itemize}' in line:
            s.append(2)
            ebene = ebene + 1
            line = line.replace('\\begin{itemize}',' ')
        if '\\begin{description}' in line:
            s.append(3)
            ebene = ebene + 1
            line = line.replace('\\begin{description}',' ')
        if '\\begin {description}' in line:
            s.append(3)
            ebene = ebene + 1
            line = line.replace('\\begin{description}',' ')
        if '\\begin{figure}' in line:
            s.append(4)
            ebene = ebene + 1
        if '\\begin {figure}' in line:
            s.append(4)
            ebene = ebene + 1
            
        if '\\begin{maxipage}' in line:
            s.append(5)
            ebene = ebene + 1
            
        if '\\begin {maxipage}' in line:
            s.append(5)
            ebene = ebene + 1
            
        if '\\begin{center}' in line:
            s.append(6)
            ebene = ebene + 1
            
        if '\\begin{tabularx}' in line:
            s.append(7)
            ebene = ebene + 1
            
        if '\\begin {center}' in line:
            s.append(6)
            ebene = ebene + 1
            
        if '\\begin {tabularx}' in line:
            s.append(7)
            ebene = ebene + 1
            
        if '\\begin {verbatim}' in line:
            s.append(8)
            ebene = ebene + 1
            
        if 'begin{verbatim}' in line:
            s.append(9)
            ebene = ebene + 1
            
        print(ebene,s,line)
        if ('\\end{' or '\\end{') in line:
            del s[-1]
            ebene = ebene - 1
        if '\\end{enumerate}' in line:
            line = line.replace('\\end{enumerate}',' ')
        if '\\end{itemize}' in line:
            line = line.replace('\\end{itemize}',' ')
        if '\\end{description}' in line:
            line = line.replace('\\end{description}',' ')
        if '\end{figure}' in line:
            line = line.replace('\\end{figure}',' ')
        if '\end{maxipage}' in line:
            line = line.replace('\\end{maxipage}',' ')
        
#Ausführung
        if '\item' in line:
        
		# ebene 1
             if ebene==1 and s[-1]==1:
                line = line.replace('\item','  - ')
            if ebene==1 and s[-1]==2:
                line = line.replace('\item','  * ')
            if ebene==1 and s[-1]==3:
                line = line.replace('\item',' ')
                line = line.replace('[','**')
                line = line.replace(']','**')
                
		# ebene 2              
        if ebene==2 and s[-1]==1:
            if '\item' in line:
                line = line.replace('\item','    - ')
        if ebene==2 and s[-1]==2:
            if '\item' in line:
                line = line.replace('\item','    * ')
        if ebene==2 and s[-1]==3:
            if '\item' in line:
                line = line.replace('\item',' ')
                line = line.replace('[','**')
                line = line.replace(']','**')
        # ebene 3                
        if ebene==3 and s[-1]==1:
            if '\item' in line:
                line = line.replace('\item','      - ')
        if ebene==3 and s[-1]==2:
            if '\item' in line:
                line = line.replace('\item','      * ')
        if ebene==3 and s[-1]==3:
            if '\item' in line:
                line = line.replace('\item',' ')
                line = line.replace('[','**')
                line = line.replace(']','**')
        
                
# \begin...\item Befehle ersetzt durch __*_ oder __-_
    
# Beginne mit überprüfung und ersetzung der Latex befehle nach Doku wiki
       
        while b < len(befehllatex):             # solange der zähler b kleiner als die maximale anzahl von elementen der liste Befehllatex
            
            if b< len(befehllatex):             # wenn zähler b kleiner ist als die anzahl der befehle
                if befehllatex[b] in line:      # wenn der an (position b in der liste befehllatex) stehende befehl in der zeile vorhanden ist:

                    posalt = line.find(befehllatex[b]) # wird ein index des alten latex befehls ermittelt 
                    posklam= line.find('}')            # und der index der ersten klammer
         
                    helpline = ''                      # die Hilfszeile wird bei jedem durchlauf geleert 
                    while posalt>posklam:              # wenn der befehl hinter der klammer steht (...versand}\index{...) so der string getrennt werden 
         
                        helpline= helpline + line[ :posklam+1]    # an der vorstehenden klammer wird abgetrennt
                        line = line[posklam+1: ]                  # an der vorstehenden klammer wird abgetrennt
                        posklam = line.find('}')                # index der ersten klammer in der geänderten Zeile wird ermittelt
                        posalt = line.find(befehllatex[b])      # index des latex befehls wird in der neuen zeile ermittelt 
         
                    
                    if posalt<posklam:                  # sobald das "plätzerücken erfolg hatte bzw der befehl vor der klammer steht 
                        
                        bearline = line[ :posklam+1]    # wird die zeile nach der klammer abgetrennt und nach bearbetete zeile geschafft  
                        line = line[posklam+1: ]        # Zeile ist jetzt alles nach der Klammerzu +1
                        bearline = bearline.replace(befehllatex[b],befehldoku[b]) # in der neuen zeile bearline wird nun der Latex befehl 
                        bearline = bearline.replace('}',befehldoku[b])            # und die Latex Klammer durch den Dokuwiki befehl ersetzt
                        line = helpline + bearline + line           # Zeile wird nun wieder zusammen gesetzt aus der hilfszeile von oben und der bearbeitungszeile und dem rest der hinter der klammerzu stand
                        posalt = 0                      # die positionen werden zurück gesetzt damit es 
                        posklam = 0                     # keine probleme mit belegten variablen gibt
              
                        
                else:
                    b=b+1               # Sollte der befehl nicht in der Zeile stehen wird b erhöht bis alle befehle geprüft worden 

                    
            if b>=len(befehllatex):     # sollten alle befehle aus der liste geprüft worden sein 
                
                dok = dok + line        # wird die Zeile an die variable Dok angehängt
        z=z+1                           # z = Zeile diese wird nach jeder Zeile um 1 erhöht 
# Ersetzen der dokuwiki befehle abgeschlossen wird für jede zeile wiederholt 


# dok ist jetzt das geaenderte Dokument wo die bekannten befehle befehllatex in befehldoku
# umgewandelt wurden jetzt werden noch andere befehle umgewandelt die nicht in den
# syntax passen
befehl = ['\Wichtig ','\Tipp','\tipp','Ã¤','Ã„','ÃŸ','Ã¼','Ãœ','Ã¶','Ã–','\,','\\\\','\\pf','\"\`','`\"','\ldots']
befehlneu = [' :!: ',' :!: ',' :!: ','ä','Ä','ß','ü','Ü','ö','Ö',' ',' ','--->','\"','\"','...']
xyz=0
while xyz<len(befehl):
    if befehl[xyz] in dok:
        dok = dok.replace(befehl[xyz],befehlneu[xyz])
    else:
        xyz=xyz+1

#print (dok)


datname2 = raw_input(' Bitte geben sie den neuen Dateinamen ohne Erweiterung an : ')
datname2 = datname2+'.txt'
file2=open(datname2,'w')            # oeffnen bzw. Erstellen der neuen Dokuwiki Datei
file2.write(dok)                    # einschreiben
file2.close                         # schließen
file2=open(datname2,'w')            # oeffnen für den fall das das erste Erstellen nicht funktioniert hat 
file2.write(dok)                    # einschreiben bzw überschreiben 
file2.close                         # schließen

# wiki txt-File  erstellt
print (' Datei konvertiert und angepasst! ') # Kontrollmeldung

