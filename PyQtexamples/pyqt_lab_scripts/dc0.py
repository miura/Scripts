#!/usr/bin/env python

#############################################################################
##
## Copyright (C) 2004-2005 Trolltech AS. All rights reserved.
##
## This file is part of the example classes of the Qt Toolkit.
##
## This file may be used under the terms of the GNU General Public
## License version 2.0 as published by the Free Software Foundation
## and appearing in the file LICENSE.GPL included in the packaging of
## this file.  Please review the following information to ensure GNU
## General Public Licensing requirements will be met:
## http://www.trolltech.com/products/qt/opensource.html
##
## If you are unsure which license is appropriate for your use, please
## review the following information:
## http://www.trolltech.com/products/qt/licensing.html or contact the
## sales department at sales@trolltech.com.
##
## This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
## WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
##
#############################################################################
#
# Original file: /usr/share/doc/PyQt4-devel-4.6.2/examples/widgets/digitalclock.py
#
# Modifications by Douglas Niehaus for EECS 448 introduction to PyQt
#
# Copyright (c) 2010 Douglas Niehaus. All Rights Reserved.  
# 
# This file may be used under GPL version 2.0 and is provided AS IS
# with NO WARRANTY OF ANY KIND.
#

# Import the QtCore and QtGUI modules, but not all the others
# 
from PyQt4 import QtCore, QtGui

# Create a DigitalClock class for this application that is derived from 
# the QLCDNumber display class defined in the QtGUI module
# 
class DigitalClock(QtGui.QLCDNumber):
    # Initialize an instance of this class. Note that we have a parent
    # class reference argument available, but that it is None by
    # default, permitting this class to be a "top" class without a
    # parent.
    #
    def __init__(self, parent=None):
        # Invoke the __init__ method of an instance of the superclass
        # of the class DigitalClock specific to the self instance of
        # DigitalClock
        #
        super(DigitalClock, self).__init__(parent)

        self.setSegmentStyle(QtGui.QLCDNumber.Filled)

        # Create a periodic timer, connect its signal on expiration to
        # the showTime() method of this class, and set the period of
        # the timer to 1000 milliseconds using the start() method.
        #
        timer = QtCore.QTimer(self)
        timer.timeout.connect(self.showTime)
        timer.start(1000)

        # Set the contents of the window for the first time by
        # invoking the showTime() method directly. Then set the titile
        # of the window, which appears in the title bar of the window,
        # and set the size of the window to 150 (width) by 60 (height)
        # pixels.
        #
        self.showTime()
        self.setWindowTitle("Digital Clock")
        self.resize(150, 60)

    
    # This method queries the system for the current time, formats
    # a string variable as desired for disply in the LCDNumber
    # display and sets the text of the display.
    #
    def showTime(self):
        time = QtCore.QTime.currentTime()
        text = time.toString('hh:mm')
        
        # Trick to implement a common LCD display convention
        # The colon will blink on and off every second
        #
        if (time.second() % 2) == 0: 
            text = text[:2] + ' ' + text[3:]

        self.display(text)

# This conditional ensures that the code within the "True" portion of
# the conditional will only be executed if the file is called as a
# comnand. If the file is imported into another file as a module, it
# will not be executed.
#
if __name__ == '__main__':
    
    import sys

    # Create an instance of QtGui.QApplication which provides the
    # framework for our application, as well as processing command
    # line arguments recognized by Qt.
    #
    app = QtGui.QApplication(sys.argv)

    # Create an instance of our application's top-level class and
    # invoke its show() method to make it visible. Note that as show()
    # is not defined in the DigitalClock class, it is obviously
    # inherited from a more fundamental base class.
    #
    clock = DigitalClock()
    clock.show()

    # We fall into this line of code at the beginning of program
    # execution, but come out of it only at the end. The app.exec_()
    # method call enters the Qt event loop and does not return until
    # the application is finished. In this case it returns an integer
    # status value which is used as the argument to sys.exit() which
    # invokes the underlying system's application exit() routine.
    #
    sys.exit(app.exec_())
