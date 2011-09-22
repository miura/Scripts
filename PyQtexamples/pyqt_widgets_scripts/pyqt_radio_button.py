#!/usr/bin/python

# RadioButtonExample

import sys
from PyQt4 import QtCore, QtGui


###########################################################
#                 RadioButtonExample Start                #
###########################################################
class RadioButtonExample(QtGui.QWidget):

    	#Dictionary to hold button names and option number
	radio_button_data = { 1:"Option 1", 2:"Option 2", 3:"Option 3"}
	
	def __init__(self, application, parent=None):
        	super(RadioButtonExample, self).__init__(parent)


		# Question Label
		self.question      = QtGui.QLabel("The Question ?")
	
		# Radio Buttons, get the text for the radio button from the 
		# Dictionary radio_button_data
		self.radio_button1 = QtGui.QRadioButton(self.radio_button_data[1])
		# set the radio_button1 to be checked by default
		self.radio_button1.setChecked(True)
		self.radio_button2 = QtGui.QRadioButton(self.radio_button_data[2])
		self.radio_button3 = QtGui.QRadioButton(self.radio_button_data[3])

		# Answer Label to hold the answer
		self.answer	   = QtGui.QLabel( "Answer Selected : [%s]" % self.radio_button_data[1])

		# Button group to hold all the radio buttons together
		self.button_group  = QtGui.QButtonGroup(self)
	
		# Add buttons to the group and assign interger id's to 
		# each radio button.
		self.button_group.addButton(self.radio_button1, 1)		
		self.button_group.addButton(self.radio_button2, 2)		
		self.button_group.addButton(self.radio_button3, 3)
	
		# Associate the button_handler SLOT with the buttonClicked(int) 
		# SIGNAL. Note that an int is passed with the bottonClicked SIGNAL.
		# The integer value passed to the SLOT is the id we associated 
		# each radio button to while adding them to the button group. 	
		self.connect(self.button_group, QtCore.SIGNAL("buttonClicked(int)"), self.button_handler)
	
		# add the labels and the buttons in a Vertical Box Layout
		self.layout	   = QtGui.QVBoxLayout()
		self.layout.addWidget(self.question)
		self.layout.addWidget(self.radio_button1)
		self.layout.addWidget(self.radio_button2)
		self.layout.addWidget(self.radio_button3)
		self.layout.addWidget(self.answer)
		
		# set widget's layout
		self.setLayout(self.layout)

		

	def button_handler(self, id):
		# get the text from the Dictionary self.radio_button_data
		self.answer.setText( "Answer Selected : [%s]" % self.radio_button_data[id])		

	
###########################################################
#                 RadioButtonExample End                  #
###########################################################


###################################################################
###################################################################
# This conditional ensures that the code within the "True" portion of
# the conditional will only be executed if the file is called as a
# command. If the file is imported into another file as a module, it
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
    example = RadioButtonExample(app)
    example.show()

    # We fall into this line of code at the beginning of program
    # execution, but come out of it only at the end. The app.exec_()
    # method call enters the Qt event loop and does not return until
    # the application is finished. In this case it returns an integer
    # status value which is used as the argument to sys.exit() which
    # invokes the underlying system's application exit() routine.
    #
    sys.exit(app.exec_())
