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
    def __init__(self, parent=None):
        super(DigitalClock, self).__init__(parent)

        self.setSegmentStyle(QtGui.QLCDNumber.Filled)

        timer = QtCore.QTimer(self)
        timer.timeout.connect(self.showTime)
        timer.start(1000)

        self.showTime()
        self.setWindowTitle("Digital Clock")
    
    def showTime(self):
        time = QtCore.QTime.currentTime()
        text = time.toString('hh:mm')
        
        if (time.second() % 2) == 0: 
            text = text[:2] + ' ' + text[3:]

        self.display(text)


# Create a NewTop class that is derived from the basic QtGui.GroupBox
# Class. This will let us arrange things as we wish, and will not use
# the QDialog window class which assumes dialog window properties, nor
# will it use the QMainWindow class which is more complex and makes
# several component and layout assumptions.
#
class NewTop(QtGui.QGroupBox):
    def __init__(self, application, parent=None):
        super(NewTop, self).__init__(parent)

        # We will use the top level widget to contain a "quit" button
        # and an instance of the Digital Clock class
        #
        quitb = QtGui.QPushButton("Quit")
        clock = DigitalClock(self)

        # Create a Vertical layout box which we will associate with
        # this top level widget, after we add the clock and then the
        # Quit button. These are added top-to-bottom
        #
        layout = QtGui.QVBoxLayout()
        layout.addWidget(clock)
        layout.addWidget(quitb)
        self.setLayout(layout)

        # Now connect the "pressed()" event of the button with the
        # closeAllWindows() method of the application as a whole, a
        # reference to which we passed in as an argument to the
        # __init__ method for this class.
        #
        self.connect(quitb, QtCore.SIGNAL("pressed()"), application.closeAllWindows) 

        # Now set the window title and set the size of the window to
        # something visible.
        #
        self.setWindowTitle("New Top Window")
        self.resize(320, 160)

if __name__ == '__main__':
    
    import sys

    app = QtGui.QApplication(sys.argv)

    # This time let us use a new top-level class which will 
    # contain an instance of the Digital Clock Class
    #
    nt = NewTop(app)
    nt.show()

    sys.exit(app.exec_())
