#!/usr/bin/python

# QCalenderWidget Example

import sys
from PyQt4 import QtCore, QtGui, Qt

class SelectDate(QtGui.QWidget):
	def __init__(self, application, parent=None):
        	super(SelectDate, self).__init__(parent)
        
		###########################################################
		#                  SelectDate Widget Start                #
        	###########################################################
        
		self.setWindowTitle('Calender Example')
        
		# In this example we will demonstrate the use of a Calender 
		# in an Application. Several applications, need date input 
		# from a user. Launching a calender and getting the required
		# date from the user is often more convenient than having
		# the user type out a date.

	
		# A button to invoke the calender
		self.button = QtGui.QPushButton("Select Date", self)
		# Connect the button's SIGNAL clicked() to the button_handler SLOT
		self.button.connect(self.button, QtCore.SIGNAL("clicked()"), self.button_handler)

		# A Label to display the selected date
		self.label = QtGui.QLabel("No Date Set")
		self.label.setAlignment(QtCore.Qt.AlignHCenter)

		# Vertical Box layout to arrange the button and the label
		self.layout = QtGui.QVBoxLayout()
		self.layout.addWidget(self.button)
		self.layout.addWidget(self.label)
	
		# set the Vertical Box layout as this widgets layout
		self.setLayout(self.layout)
		

		# Create an instance of the QCalenderWidget
		self.calendar = QtGui.QCalendarWidget()
		# hide the calender intially
		self.calendar.hide()
		# associate SLOT selection_changed with the QCalender Widget's selectionChanged() SIGNAL
		self.calendar.connect(self.calendar, QtCore.SIGNAL("selectionChanged()"), self.selection_changed)

	
	def button_handler(self):
		# When button is pressed, hide the button and the label and show the calender
		self.button.hide()
		self.label.hide()
		self.calendar.show()


	def selection_changed(self):
		# Get the selected date
		date = self.calendar.selectedDate()
		# hide the calender and show the button and the label
		self.calendar.hide()
		self.button.show()
		self.label.setText(date.toString())
		self.label.show()	
		



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
    	example = SelectDate(app)
    	example.show()

    	# We fall into this line of code at the beginning of program
    	# execution, but come out of it only at the end. The app.exec_()
    	# method call enters the Qt event loop and does not return until
    	# the application is finished. In this case it returns an integer
    	# status value which is used as the argument to sys.exit() which
    	# invokes the underlying system's application exit() routine.
    	#
    	sys.exit(app.exec_())
