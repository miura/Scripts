# -*- coding: utf-8 -*-
"""
Created on Thu Jul 28 02:15:37 2011

@author: Kota
"""

from jpype import *
#startJVM("C:/Sun/SDK/jdk/jre/bin/client/jvm.dll", "-Djava.class.path=C:/imagej2/ij.jar")
startJVM("C:/Program Files/Java/jdk1.6.0_20/jre/bin/client/jvm.dll", "-Djava.class.path=C:/imagej/ij.jar")
ij = JPackage('ij')
imp = ij.IJ.openImage("http://rsb.info.nih.gov/ij/images/lena.jpg")
print(imp.getTitle())
imp.show()
ij.IJ.makeLine(0,0,100,100)
pp = ij.gui.ProfilePlot(imp)
pp.createWindow()
