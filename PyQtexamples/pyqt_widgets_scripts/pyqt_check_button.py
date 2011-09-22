#!/usr/bin/python

# Create some simple PyQt CheckBoxes

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
        self.setWindowTitle('QCheckBox Example')

    ###########################################################
    #                  Example Widget Start                   #
    ###########################################################

	# Here we create a simple check box, and set it to be
	# togglable, so that it can be checked and unchecked
	#
	self.lang_check_box = QtGui.QCheckBox('English', self)
	self.lang_check_box.toggle()
	# Here we connect check box to a method. The stateChanged method
	# is a default signal emitted by the check box widget when it is
	# checked or unchecked by the user.
	#
	self.connect(self.lang_check_box, QtCore.SIGNAL('stateChanged(int)'), self.langAction)
        # Here we are centering the language in the WidgetExample object
	#
        self.lang_check_box.move(20, 5)
        

	# Here we create another check box, to illustrate that
	# multiple check boxes can be set at any give time.
	#
	self.color_check_box = QtGui.QCheckBox('Red', self)
	self.color_check_box.toggle()
	# Here we connect check box to a method. The stateChanged method
	# is a default signal emitted by the check box widget when it is
	# checked or unchecked by the user.
	#
	self.connect(self.color_check_box, QtCore.SIGNAL('stateChanged(int)'), self.colorAction)
        # Here we are centering the language in the WidgetExample object
	#
        self.color_check_box.move(20, 25)
	
	# Now we will add a simple label to display changes made when we
	# select different check boxes
	#
        self.check_box_display = QtGui.QLabel("Libertas", self)
	self.check_box_display.setStyleSheet("QWidget { background-color: Red }")
        
	# Here we are centring the label in the WidgetExample object
	#
#	self.check_box_display.move(120, 15)
	self.check_box_display.setGeometry(120, 15, 30, 30)
    
    # This is the action we wish to occur when the button is clicked.
    # It simply changes the label on the button, but it could easily
    # do much much more. Also note that because the button now has state,
    # we can check for that state inside any actions it is connected to.
    # This is ideal for toggling other portions of an application on or off.
    #
    def langAction(self, selected):
        if self.lang_check_box.isChecked():
            self.check_box_display.setText("Libertas")
        else:
	    self.check_box_display.setText("Freedom")
    
    # This is the action we wish to occur when the button is clicked.
    # It simply changes the label on the button, but it could easily
    # do much much more. Also note that because the button now has state,
    # we can check for that state inside any actions it is connected to.
    # This is ideal for toggling other portions of an application on or off.
    #
    def colorAction(self, selected):
        if self.color_check_box.isChecked():
            self.check_box_display.setStyleSheet("QWidget { background-color: Red }")
        else:
	    self.check_box_display.setStyleSheet("QWidget { background-color: Blue }")
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
