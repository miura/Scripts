#!/usr/bin/python

# Create a simple PyQt label

import sys
from PyQt4 import QtCore, QtGui

# This is a useful utility routine than can help you figure out which
# widget is going where in your GUI as you build it, or when you are
# trying to figure out an example. Just call it on any widget and its
# background color is set to a red that is hard to miss.
def make_widget_red(widget):
    widget.setAutoFillBackground(True)
    palette = widget.palette()
    palette.setColor(widget.backgroundRole(), QtGui.QColor(255,0,0))
    widget.setPalette(palette)


###################################################################
###################################################################
# This is the Qt Widget class which we will use to hold our widget 
# examples. It serves only to provide a framework in which to display
# the given widget for this example.
#
class FrameExample(QtGui.QWidget):
    def __init__(self, application, parent=None):
        super(FrameExample, self).__init__(parent)

	# This sets the size and window title for the WidgetExample
	# class. Here we are setting the WidgetExample to appear at
	# screen coordinates x:300 y:300 when displayed, and the
	# WidgetExample itself to be 200 x 50 pixels in size. The title
	# for the object is 'Widget Example'
	#
        self.setGeometry(300, 300, 200, 50)
        self.setWindowTitle('Frame Example')

        ###########################################################
	#                  Example Widget Start                   #
        ###########################################################
	self.rootframe	= QtGui.QFrame(self)
	self.rootframe.setFrameShape(QtGui.QFrame.WinPanel)
	self.rootframe.setFrameRect(QtCore.QRect(0,250,150,0))
	self.rootframe.setFrameShadow(QtGui.QFrame.Raised)
	self.rootframe.setLineWidth(3)

        # Un-comment this line if you want to see the frame turn red
        #
        # make_widget_red(self.rootframe)
	
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
    example = FrameExample(app)
    example.show()

    # We fall into this line of code at the beginning of program
    # execution, but come out of it only at the end. The app.exec_()
    # method call enters the Qt event loop and does not return until
    # the application is finished. In this case it returns an integer
    # status value which is used as the argument to sys.exit() which
    # invokes the underlying system's application exit() routine.
    #
    sys.exit(app.exec_())
