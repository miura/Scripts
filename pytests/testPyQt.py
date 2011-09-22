# -*- coding: utf-8 -*-
"""
Created on Thu Jul 28 18:58:47 2011

@author: -
"""

import sys
from PyQt4.QtGui import *
app = QApplication(sys.argv)
button = QPushButton("Hello World", None)
button.show()
app.exec_()