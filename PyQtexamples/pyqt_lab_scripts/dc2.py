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
    # Create some class attributes that are constant across all
    # instances and so are defined outide the scope of all methods
    #
    format1 = 1
    format2 = 2
    format3 = 3

    formats = {1:("hh:mm",5, 1000), 2:("hh:mm:ss",8,1000), 3:("hh:mm:ss.zzz",10,100)}

    def __init__(self, parent=None):
        super(DigitalClock, self).__init__(parent)

        # Used the filled LCD stype and the first time format by default
        #
        self.setSegmentStyle(QtGui.QLCDNumber.Filled)
        self.format = self.format1

        # Set up the timer with the period appropriate tot he format
        #
        self.timer = QtCore.QTimer(self)
        self.timer.timeout.connect(self.showTime)
        self.timer.start(self.formats[self.format][2])

        # Display the time and set the Window Title to finish
        # initialization
        #
        self.showTime()
        self.setWindowTitle("Digital Clock")
    
    def showTime(self):
        """
        This routime is called every time the timer goes off, or when
        the user chooses a different format.
        """
        # Get the current time and convert it to a string according to 
        # the standard QTime formats
        #
        time = QtCore.QTime.currentTime()
        text = time.toString(self.formats[self.format][0])
        
        # Play the blinking colon trick for format1 and shave the 
        # last two decimals fromt he milliseconds for format3
        #
        if ((self.format == self.format1) and (time.second() % 2)): 
            text = text[:2] + ' ' + text[3:]
        
        if ( self.format == self.format3 ): 
            text = text[:-2]
        
        self.display(text)

    def change_format(self, format_id):
        """
        The user clicked a radio button to change the format, whose
        number is supplied as the argument to this routine. Adjust the
        timer period and the number of digits in the display according
        tot he settings for the new format.
        """
        self.format = format_id
        self.timer.stop()
        self.timer.start(self.formats[self.format][2])
        self.setNumDigits(self.formats[self.format][1])
        self.showTime()

# Top class that serves to contain the top-level elements of the
# application permitting us to provide a layout and is convenient for
# adding elements to the application
#
class NewTop(QtGui.QGroupBox):
    def __init__(self, application, parent=None):
        super(NewTop, self).__init__(parent)

        # We want the digital clock at the top, with 
        # an intermediate groupbox letting us choose among
        # formats for the clock
        #
        quitb = QtGui.QPushButton("Quit")
        self.clock = DigitalClock()

        # Use a Group Box to hold three radio buttons giving a choice
        # of three formats for the clock: hh:mm, hh:mm:ss, and
        # hh:mm:ss.ms. Arrange these buttons left-to-right in an HBox.
        #
        formats = QtGui.QGroupBox("Clock Format")

        self.fmt1 = QtGui.QRadioButton(self.clock.formats[self.clock.format1][0])
        self.fmt2 = QtGui.QRadioButton(self.clock.formats[self.clock.format2][0])
        self.fmt3 = QtGui.QRadioButton(self.clock.formats[self.clock.format3][0])

        self.fmt1.setChecked(True)

        fmt_layout = QtGui.QHBoxLayout()
        fmt_layout.addWidget(self.fmt1)
        fmt_layout.addWidget(self.fmt2)
        fmt_layout.addWidget(self.fmt3)
        fmt_layout.addStretch(1)
        formats.setLayout(fmt_layout)

        # Use a Button Group to group the three radio format buttons
        # and to be notifieed when one of them is clicked. We add them
        # with different IDs within the group, and use the form of the
        # signal with an ID associated so the change_format() method
        # is given the ID of the format requested.
        #
        self.fmt_group = QtGui.QButtonGroup()
        self.fmt_group.addButton(self.fmt1, self.clock.format1)
        self.fmt_group.addButton(self.fmt2, self.clock.format2)
        self.fmt_group.addButton(self.fmt3, self.clock.format3)
        self.connect(self.fmt_group, QtCore.SIGNAL("buttonClicked(int)"), self.change_format)

        # Create a Vertical layout box which we will associate with
        # this top level widget, after we add the clock and then the
        # Quit button. These are added top-to-bottom
        #
        layout = QtGui.QVBoxLayout()
        layout.addWidget(self.clock)
        layout.addWidget(formats)
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
        self.setWindowTitle("new Top Window")
        self.resize(320, 260)

    def change_format(self):
        # Called when the user uses a radio button to select a new
        # clock format
        #
        self.clock.change_format(self.fmt_group.checkedId())


if __name__ == '__main__':
    
    import sys

    app = QtGui.QApplication(sys.argv)

    # This time let us use a new top-level class which will 
    # contain an instance of the Digital Clock Class
    #
    nt = NewTop(app)
    nt.show()

    sys.exit(app.exec_())
