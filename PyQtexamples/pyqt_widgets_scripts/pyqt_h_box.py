#!/usr/bin/python

# Create a simple PyQt label

import sys
from PyQt4 import QtCore, QtGui


###################################################################
###################################################################
# This is the Qt Widget class which we will use to hold our widget 
# examples. It serves only to provide a framework in which to display
# the given widget for this example.
#
class WidgetExample(QtGui.QWidget):
    def __init__(self, application, parent=None):
        super(WidgetExample, self).__init__(parent)

	# This sets the size and window title for the WidgetExample
	# class. Here we are setting the WidgetExample to appear at
	# screen coordinates x:300 y:300 when displayed, and the
	# WidgetExample itself to be 200 x 50 pixels in size. The title
	# for the object is 'Widget Example'
	#
        self.setGeometry(300, 300, 200, 50)
        self.setWindowTitle('QHboxLayout Example')



        ###########################################################
	#                  Example Widget Start                   #
        ###########################################################

	# Here we are creating two labels and two push buttons
	# to add to the Horizontal layout object.
        self.label1 = QtGui.QLabel("This is the label 1", self)
	self.label1.setLineWidth(3)
	self.label1.setFrameShape(QtGui.QFrame.Box)
	self.label1.setFrameShadow(QtGui.QFrame.Raised)
	
        self.label2 = QtGui.QLabel("This is the label 2", self)
	self.label2.setLineWidth(3)
	self.label2.setFrameShape(QtGui.QFrame.Box)
	self.label2.setFrameShadow(QtGui.QFrame.Raised)

	self.button1 = QtGui.QPushButton("Button1")
	self.button2 = QtGui.QPushButton("Button2")

        # Create a Layout Object and then add widgets to it from Left
        # to Right
	self.hbox_layout = QtGui.QHBoxLayout()
	self.hbox_layout.addWidget(self.label1)
	self.hbox_layout.addWidget(self.label2)
	self.hbox_layout.addWidget(self.button1)
	self.hbox_layout.addWidget(self.button2)

	# Set the Horizontal layout object as the WidgetExample's 
	# layout object
	self.setLayout(self.hbox_layout)
	
        ###########################################################
	#                   Example Widget End                    #
        ###########################################################


###################################################################
###################################################################
# This conditional ensures that the code within the "True" portion of
# the conditional will only be executed if the file is called as a
# comnand. If the file is imported into another file as a module, it
# will not be executed.
#
if __name__ == '__main__':
    
    # Create an instance of QtGui.QApplication which provides the
    # framework for our application, as well as processing command
    # line arguments recognized by Qt.
    #
    app = QtGui.QApplication(sys.argv)

    # Create an instance of our application's top-level class and
    # invoke its show() method to make it visible. Note that as show()
    # is not defined in the WidgetExample class, it is obviously
    # inherited from a more fundamental base class.
    #
    example = WidgetExample(app)
    example.show()

    # We fall into this line of code at the beginning of program
    # execution, but come out of it only at the end. The app.exec_()
    # method call enters the Qt event loop and does not return until
    # the application is finished. In this case it returns an integer
    # status value which is used as the argument to sys.exit() which
    # invokes the underlying system's application exit() routine.
    #
    sys.exit(app.exec_())
