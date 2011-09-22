#!/usr/bin/python

# Create a simple PyQt Combo Box

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
        self.setWindowTitle('QComboBox Example')

    ###########################################################
    #                  Example Widget Start                   #
    ###########################################################

        # Here we create the combo box. Note that it is initially
	# empty. We have to create items and add them to the combo
	# box. Here we just add three simple items. 
	#
        self.combo_box = QtGui.QComboBox(self)
	self.combo_box.addItem(" One ")
	self.combo_box.addItem(" Two ")
	self.combo_box.addItem("Three")
	# Here we connect our combo box to a method. The currentIndexChanged
	# method is a default signal emitted by the combo box widget when
	# another element is selected by the user.
	#
	self.connect(self.combo_box, QtCore.SIGNAL('currentIndexChanged(QString)'), self.buttonAction)

	# Here we are centering the combo box in the WidgetExample object
	#
        self.combo_box.move(20, 12.5)

	# Now we will add a simple label to display changes made when we
	# select different items in the combo-box
	#
        self.combo_box_display = QtGui.QLabel("Uno", self)
        
	# Here we are centring the label in the WidgetExample object
	#
	self.combo_box_display.move(120, 15)
    
    # This is the action we wish to occur when the button is clicked.
    # It simply changes the label on the button, but it could easily
    # do much much more. Also note that because the button now has state,
    # we can check for that state inside any actions it is connected to.
    # This is ideal for toggling other portions of an application on or off.
    #
    def buttonAction(self, selected):
        if selected == (" One "):
            self.combo_box_display.setText("Uno")
	elif selected == (" Two "):
	    self.combo_box_display.setText("Dos")
        else:
            self.combo_box_display.setText("Tres")
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
