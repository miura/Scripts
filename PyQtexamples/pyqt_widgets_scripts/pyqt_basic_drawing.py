#!/usr/bin/env python

#############################################################################
## This is a basic drawing example that demonstrates basic drawing
## capability in a widget
#############################################################################

from PyQt4 import QtCore, QtGui


class MyWidget(QtGui.QWidget):
    
    def __init__(self):
        super(MyWidget, self).__init__()
        
	self.setWindowTitle("BasicDrawing")
        self.resize(100, 100)
	
    

    def paintEvent(self, event):
        """
        This handler manages the painting of the Widget.
        """
	# get an instance of the QPinter object for this widget
        painter = QtGui.QPainter(self)
	# setting this hint helps smoothening the drawing of slant
	# lines
        painter.setRenderHint(QtGui.QPainter.Antialiasing)
	# line from point (0,0) to (100,100)
	painter.drawLine(0,0, 100,100)
	# create a QColor instance 
	redColor = QtGui.QColor(255,0,0)
	# create a QBrush instance
	brush = QtGui.QBrush(redColor)
	# set brush for drawing
	painter.setBrush(brush)
	# draw a rect with top left at (10, 10) and width and hight
	# of 30 and 30
	painter.drawRect(10,10, 30,30)



if __name__ == "__main__":

    import sys

    app = QtGui.QApplication(sys.argv)
    # Create an instance of the MyWidget class
    myWidget = MyWidget()
    myWidget.show()
    sys.exit(app.exec_())
