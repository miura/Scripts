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

	# Set the Window Title for this example
        self.setWindowTitle('Slider Example')

        ###########################################################
	#                  Example Widget Start                   #
        ###########################################################
        
        # Create a VBox Layout for the widget as a whole
        main_layout = QtGui.QVBoxLayout()
        self.setLayout(main_layout)

        # Create a Frame to hold two labels side by side. One to give
        # the coordinate of the slider, and one to tell the user
        # that is what it is. Create an HBoxLayout for the Frame
        label_frame  = QtGui.QFrame()
        label_layout = QtGui.QHBoxLayout()
        label_frame.setLayout(label_layout)

        # The frame is flat and not visibly distinguished from the
        # background of its parent widget, so un-comment this line of
        # you want to see where it is.
        # make_widget_red(label_frame)

        # Create the labels
        self.coord_value = QtGui.QLabel()
        coord_label = QtGui.QLabel()
        coord_label.setText("Slider Coord Value: ")

        # Add the Labels to the HBox of the frame
        label_layout.addWidget(coord_label)
        label_layout.addWidget(self.coord_value)

        # Create the Slider. Note that this class inherits from
        # AbstractSlider where most of the capabilities are defined.
        # Set minimum and maximum values. Set the initial value and
        # reflect this in the label giving the value
        slider = QtGui.QSlider(QtCore.Qt.Horizontal)
        slider.setMinimum(0)
        slider.setMaximum(100)
        slider.setValue(0)
        self.coord_value.setText(QtCore.QString.number(slider.value()))

        # Now connect a signal produced by the slider when the handle
        # is moved to a routine that will update the label giving its
        # position. Note that clicking the mouse on the slider bed
        # causes the value fo the slider to change, but it is a
        # different signal. So, add a hadler for that as well. We
        # define a different routine, although it could be the same
        # one.
        self.connect(slider, QtCore.SIGNAL("sliderMoved(int)"), self.slider_moved)
        self.connect(slider, QtCore.SIGNAL("valueChanged(int)"), self.slider_clicked)

        # Add the label_frame and the slider to the main layout
        main_layout.addWidget(label_frame)
        main_layout.addWidget(slider)

    def slider_moved(self, position):
        self.coord_value.setText(QtCore.QString.number(position))
        
    def slider_clicked(self, position):
        self.coord_value.setText(QtCore.QString.number(position))
        

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
