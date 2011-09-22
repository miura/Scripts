from jpype import *

startJVM("C:/Sun/SDK/jdk/jre/bin/client/jvm.dll", "-Djava.class.path=C:/imagej2/ij.jar")
ij = JPackage('ij')
imp = ij.IJ.openImage("http://rsb.info.nih.gov/ij/images/lena.jpg")
print(imp.getTitle())
imp.show()
ij.IJ.makeLine(0,0,100,100)
pp = ij.gui.ProfilePlot(imp)
pp.createWindow()
imp2 = ij.WindowManager.getCurrentImage()
print(imp2.getWidth())




