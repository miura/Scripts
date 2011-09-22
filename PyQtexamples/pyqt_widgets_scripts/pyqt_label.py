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
	# for the object is 'Widget Example'.
	#
        self.setGeometry(300, 300, 200, 50)
        self.setWindowTitle('QLabel Example')

    ###########################################################
    #                  Example Widget Start                   #
    ###########################################################

	# Here we are creating the actual QLabel which this
	# example serves to illustrate. Note that the Label is
	# one of the most basic Qt widgets. Here we simply set
	# it to display a string and give it a border so that it
	# may be easily identified. Labels can also be used to display
	# images and videos instead of just strings.
	#
        self.label = QtGui.QLabel("This is the label", self)

        # When putting a border around the label, we are accessing
	# portins of the Qt Frame API. This is because the PyQt Label
	# class extends the PyQt Frame class, which causes it to
	# inherit all of its methods.
	#
        self.label.setLineWidth(3)
	self.label.setFrameShape(QtGui.QFrame.Box)
	self.label.setFrameShadow(QtGui.QFrame.Raised)
	
        # Here we are centering the label in the WidgetExample object
        self.label.move(50, 12.5)

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
