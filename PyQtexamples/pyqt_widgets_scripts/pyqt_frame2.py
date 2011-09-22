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
        self.setWindowTitle('Frame Example')

        ###########################################################
	#                  Example Frame Start                   #
        ###########################################################

        # A frame is really simple, but can be useful in visually
        # grouping things within a GUI. 
        # 
        # Check the WWW page for a full description of the frame Class 
        # http://www.riverbankcomputing.co.uk/static/Docs/PyQt4/html/qframe.html
        #
        self.frame = QtGui.QFrame()

        # Frames have Shapes and Shadow styles. 
        # The set of spahes is: 
        # NoFrame, Box, Panel, StyledPanel, HLine and VLine
        #
        # Try setting this parameter to its various values to see the
        # effect
        self.frame.setFrameShape(QtGui.QFrame.Panel)

        # Frames also have line widths -try changing this parameter
        self.frame.setLineWidth(5)

        # Frames also have a Shadow attribute. The possible values
        # are: Plain, Raised and Sunken. Try different values.
	self.frame.setFrameShadow(QtGui.QFrame.Raised)

        #######################################################
        # Below here we are defining labels and Vboxes to arrange
        # elements in the frame defined above, as well as placing
        # the frame in the window as a whole.
        #######################################################

        # We need the frame to surround something to see it, so we use
        # two of the 3 labels in a VBox from a previous example.
        # Note that we set the VBox to be the layout of the FRAME not
        # of the widget we are initializing. This is because the 
        # frame surrounds all the widget contents.
        self.vbox = QtGui.QVBoxLayout()
        self.frame.setLayout(self.vbox)
        
        # UN-comment this line and see where the frame is. Note that
        # the background of the labels is essentially transparent, as
        # we saw in a previous example, but the buttons are not
        #
        make_widget_red(self.frame)

        # Now create a VBox for the widget as a whole and put the
        # two buttons in first and then the frame for the labels.
        self.vbox2 = QtGui.QVBoxLayout()
        self.setLayout(self.vbox2)

        # However, we have to have some widgets to put in the Frame
        # and in the widget to see how placement works. We create 2
        # labels and two buttons like in VBox example to show how the
        # layout for the frame arranges things being grouped by the
        # Frame vs. those place in the Widget VBox layout.
        self.label1 = QtGui.QLabel("Label 1", self)
        self.label1.setLineWidth(3)
	self.label1.setFrameShape(QtGui.QFrame.Box)
	self.label1.setFrameShadow(QtGui.QFrame.Raised)
        
        # You can make the background of the label alone red
        # make_widget_red(self.label1)
	
        self.label2 = QtGui.QLabel("Label 2", self)
        self.label2.setLineWidth(3)
	self.label2.setFrameShape(QtGui.QFrame.Box)
	self.label2.setFrameShadow(QtGui.QFrame.Raised)

        # Create the familiar two buttons
	self.button1 = QtGui.QPushButton("Button1")
	self.button2 = QtGui.QPushButton("Button2")

        # add the two labels to the Widget's VBox
        self.vbox2.addWidget(self.label1)
        self.vbox2.addWidget(self.label2)

        # Add the buttons tot he Frame's vbox layout
        self.vbox.addWidget(self.button1)
        self.vbox.addWidget(self.button2)

        # Add the Frame to the widget's vbox
        self.vbox2.addWidget(self.frame)

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
