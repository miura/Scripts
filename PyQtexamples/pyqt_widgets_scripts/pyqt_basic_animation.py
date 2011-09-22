#!/usr/bin/env python

#############################################################################
## This is a basic drawing example that demonstrates basic animation
## capability a widget. It is similar to the pyqt_basic_drawing.py
## with the line moving.
#############################################################################

from PyQt4 import QtCore, QtGui


class MyWidget(QtGui.QWidget):
    
    def __init__(self):
        super(MyWidget, self).__init__()
        
	self.setWindowTitle("BasicDrawing")
        self.resize(100, 100)

	# Line coordinate here is a drawing state
	self.lineCoordinates = QtCore.QLineF(0,0,0,100)
	self.timer = QtCore.QTimer()
	self.timer.timeout.connect(self.expires)
	self.timer.start(100)
	self.x = 0
	

    def expires(self):
	# the timer expires callback, modifies the line coordinate
	# state
	self.x = self.x + 1
	if self.x  >= 100:
		self.x = 0
	self.lineCoordinates = QtCore.QLineF(self.x,0,self.x,100)
	# call to self.update causes screen to be refreshed,
	# i.e. paintEvent to be called
	self.update()
			
    

    def paintEvent(self, event):
        """
        This handler manages the painting of the Widget.
        """
	# get an instance of the QPainter object for this widget
        painter = QtGui.QPainter(self)
	# setting this hint helps smoothening the drawing of slant
	# lines
        painter.setRenderHint(QtGui.QPainter.Antialiasing)
	# draw line based on the lineCoordinates
	painter.drawLine(self.lineCoordinates)
	# create a QColor instance 
	redColor = QtGui.QColor(255,0,0)
	# create a QBrush instance
	brush = QtGui.QBrush(redColor)
	# set brush for drawing
	painter.setBrush(brush)
	# draw a rectangle with top left at (10, 10) and width and
	# hight of 30 and 30
	painter.drawRect(10,10, 30,30)



if __name__ == "__main__":

    import sys

    app = QtGui.QApplication(sys.argv)
    # Create an instance of the MyWidget class
    myWidget = MyWidget()
    myWidget.show()
    sys.exit(app.exec_())
