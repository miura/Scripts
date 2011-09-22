# -*- coding: utf-8 -*-
"""
Created on Wed Jul 27 11:50:26 2011

@author: -
"""

import sys 
from PyQt4 import QtGui 

app = QtGui.QApplication(sys.argv) 
widget = QtGui.QWidget() 
widget.resize(250, 150) 
widget.setWindowTitle('simple') 
widget.show() 
sys.exit(app.exec_()) 