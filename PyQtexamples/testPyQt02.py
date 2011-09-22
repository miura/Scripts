# -*- coding: utf-8 -*-
"""
Created on Tue Aug 02 10:56:23 2011

@author: Miura
"""

#!/usr/bin/python

# simple.py

import sys
from PyQt4 import QtGui

app = QtGui.QApplication(sys.argv)

widget = QtGui.QWidget()
widget.resize(250, 150)
widget.setWindowTitle('simple')
widget.show()

sys.exit(app.exec_())