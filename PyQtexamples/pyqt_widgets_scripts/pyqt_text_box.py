#!/usr/bin/python

# Create a simple PyQt label

import sys
from PyQt4 import QtCore, QtGui

# This is a useful utility routine than can help you figure out which
# widget is going where in your GUI as you build it, or when you are
# trying to figure out an example. Just call it on any widget and its
# background color is set to a red that is hard to miss.
def make_widget_red(widget):
    widget.setAutoFillBackground(True)
    palette = widget.palette()
    palette.setColor(widget.backgroundRole(), QtGui.QColor(255,0,0))
    widget.setPalette(palette)

###################################################################
###################################################################
# This is the Qt Widget class which we will use to hold our widget 
# examples. It serves only to provide a framework in which to display
# the given widget for this example.
#
class WidgetExample(QtGui.QWidget):
    def __init__(self, application, parent=None):
        super(WidgetExample, self).__init__(parent)

	# Set the title of the main widget
        self.setWindowTitle('QLineEdit and QText Example')

        ###########################################################
	#                  Example Widget Start                   #
        ###########################################################

        # Create a layout for the window as a whole
        main_layout = QtGui.QVBoxLayout()
        self.setLayout(main_layout)

        # Creating a QLineEdit (A single lined text box) with the text
        # inital text, which is initially selected, giving a clue to
        # its function.
	self.type_line = QtGui.QLineEdit('Type here to record a line', self)
        self.type_line.selectAll()
        main_layout.addWidget(self.type_line)

        # Note: You can set the text of a QLineEdit with setText() and
        # get the text of a QLineEdit with text().

        # Now, create a text box to record what is type in the
        # lineEdit box. Set its mode to ReadOnly becasue we only want
        # it to log what is typed on the line edit widget, not to let
        # users type in it directly
        self.line_log = QtGui.QTextEdit()
        self.line_log.setReadOnly(True)
        main_layout.addWidget(self.line_log)
        self.line_log.setText(" Line Edit Text Logger")
        self.line_log.append("======================")

        # Now, connect that signal indicating that returned has been
        # pressed in the line edit box, to a routine that will get the
        # text type, erase the box, and then add the line to the
        # logging box.
        self.connect(self.type_line, QtCore.SIGNAL("returnPressed()"), self.line_typed)

    def line_typed(self):
        command_text = "> " + self.type_line.text()
        self.line_log.append(command_text)
        self.type_line.clear()


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
