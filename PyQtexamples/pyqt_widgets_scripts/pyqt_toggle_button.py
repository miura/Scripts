#!/usr/bin/python

# Create a simple PyQt Toggle Button

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
        self.setWindowTitle('QPushButton Example')

    ###########################################################
    #                  Example Widget Start                   #
    ###########################################################

	# Here we are creating a Toggle Button, which is a button
	# with two states. It switches states every time it is pressed.
	# These states are 'Checked' and 'Unchecked'.
	# To create a toggle button, we just use a special attribute of
	# the QPushButton class.
	#
        self.push_button = QtGui.QPushButton('The Button is UnChecked', self)

        # Here we turn on the checkable configuration option for the
	# push button. With this turned on, the button will keep track of
	# its state. It defaults to 'unchecked'.
	#
        self.push_button.setCheckable(True)

        # Here we are connecting the button's 'clicked()' signal with a
	# a specific action, so that the action will be performed when
	# the button is clicked.
	#
	self.connect(self.push_button, QtCore.SIGNAL('clicked()'), self.buttonAction)

        # Here we are centering the push button in the WidgetExample object
        self.push_button.move(15, 12.5)


    # This is the action we wish to occur when the button is clicked.
    # It simply changes the label on the button, but it could easily
    # do much much more. Also note that because the button now has state,
    # we can check for that state inside any actions it is connected to.
    # This is ideal for toggling other portions of an application on or off.
    #
    def buttonAction(self):
	if self.push_button.isChecked():
            self.push_button.setText('The Button is Checked')
	else:
            self.push_button.setText('The Button is UnChecked')
        
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
