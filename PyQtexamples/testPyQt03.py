# -*- coding: utf-8 -*-
"""
Created on Tue Aug 02 10:58:15 2011

@author: Miura
http://zetcode.com/tutorials/pyqt4/firstprograms/
"""

#!/usr/bin/python

# icon.py

import sys
from PyQt4 import QtGui


class Icon(QtGui.QWidget):
    def __init__(self, parent=None):
        QtGui.QWidget.__init__(self, parent)

        self.setGeometry(300, 300, 250, 150)
        self.setWindowTitle('Icon')
        self.setWindowIcon(QtGui.QIcon('icons/web.png'))


app = QtGui.QApplication(sys.argv)
icon = Icon()
icon.show()
sys.exit(app.exec_())