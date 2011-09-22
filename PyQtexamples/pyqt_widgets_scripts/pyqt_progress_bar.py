#!/usr/bin/python

# Create a simple PyQt Progres Bar

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
        self.setWindowTitle('QProgressBar Example')

    ###########################################################
    #                  Example Widget Start                   #
    ###########################################################

        # Create the progressbar object and set its parent widget to
        # this widget.
        self.progressBar = QtGui.QProgressBar(self)

        # Set the range of the ProgressBar, the current value of the
        # progressBar is displayed as a percentage of this range. For
        # example if the value was 50 and the range [1,100] the
        # progress bar would show a value of 50%. If the value was 50
        # and the range was [1,200] the progressBar would show a value
        # of 25%.
        self.progressBar.setRange(1,100)


        # Here we are centering the progressBar in the WidgetExample object
        self.progressBar.move(50, 12.5)

        # Initialize the timer with no arguments. This just creates
        # the timer object, it does not actually start a timer.
        self.timer = QtCore.QTimer()
        
        # As its name suggests the start() method begins the timer's
        # countdown and takes two arguments: 
        # 1) The timer interval in milliseconds (1/1000th of a second) 
        # 2) The parent obeject of the timer (should normally be self)
        self.timer.start(100)
	

        # Every 100ms the timer will expire causing a 'timeout()'
        # signal to be generated. Tell PyQt that this widget is going
        # to catch this signal and use the method "timerEventHandler"
        # to execute the code relating the that partiuclar signal.
        self.connect(self.timer, QtCore.SIGNAL('timeout()'),
                     self.timerEventHandler)
    

    def timerEventHandler(self):
        """
        This method finds value of the progress bar and increments it
        by one. This method is called every time the timer expires.
        """
        value = self.progressBar.value()
        value += 1
        self.progressBar.setValue(value)

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
