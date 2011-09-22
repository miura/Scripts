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

from PyQt4 import QtCore, QtGui



class ShapeItem(object):
    """
    This class stores a shape item attributes like path, position,
    color etc.
    """	
    def __init__(self):    
        self.myPath = QtGui.QPainterPath()
        self.myPosition = QtCore.QPoint()
        self.myColor  = QtGui.QColor()
        self.myToolTip = ''

    def path(self):
        return self.myPath

    def position(self):
        return self.myPosition

    def color(self):
        return self.myColor

    def toolTip(self):
        return self.myToolTip

    def setPath(self, path):
        self.myPath = path

    def setToolTip(self, toolTip):
        self.myToolTip = toolTip

    def setPosition(self, position):
        self.myPosition = position

    def setColor(self, color):
        self.myColor = color


class SortingBox(QtGui.QWidget):
    circle_count = square_count = triangle_count = 1

    def __init__(self):
        super(SortingBox, self).__init__()

        # create the circle, square and triangle painter path objects
	self.circlePath = QtGui.QPainterPath()
        self.squarePath = QtGui.QPainterPath()
        self.trianglePath = QtGui.QPainterPath()

	# List of shape Items. This is list that holds objects of the
	# class type ShapeItem. 
	self.shapeItems = []        

	# variable to hold the previous position
        self.previousPosition = QtCore.QPoint()

        self.setMouseTracking(True)
        self.setBackgroundRole(QtGui.QPalette.Base)
	
	# reference to the item that would be moved
        self.itemInMotion = None

	# draw all the 3 shapes to some initial positions
        self.circlePath.addEllipse(0, 0, 100, 100)
        self.squarePath.addRect(0, 0, 100, 100)

        x = self.trianglePath.currentPosition().x()
        y = self.trianglePath.currentPosition().y()
        self.trianglePath.moveTo(x + 120 / 2, y)
        self.trianglePath.lineTo(0, 100)
        self.trianglePath.lineTo(120, 100)
        self.trianglePath.lineTo(x + 120 / 2, y)

        self.setWindowTitle("Tooltips")
        self.resize(500, 300)
	
	helpText = ": You can move this item around"

        # Call to createShapeItem method to create ShapeItem class
        # objects for the 3 shapes and add them to the shapeItems
        # list.
        self.createShapeItem(self.circlePath, "Circle" + helpText ,
                self.initialItemPosition(self.circlePath),
                self.initialItemColor())
        self.createShapeItem(self.squarePath, "Square" + helpText,
                self.initialItemPosition(self.squarePath),
                self.initialItemColor())
        self.createShapeItem(self.trianglePath, "Triangle" + helpText,
                self.initialItemPosition(self.trianglePath),
                self.initialItemColor())
    
    def event(self, event):
        """ 
        This is the generic event callback. Notice that we are
        checking to see if the event is tool tip so that we can
        display the tooltip in case the event is tooltip
        """
        if event.type() == QtCore.QEvent.ToolTip:
            helpEvent = event
            # Call to itemAt tells if the mouse tip position is in the
            # item or not.
            index = self.itemAt(helpEvent.pos())
            if index != -1:
                # if the mouse pointer is in the item, then show the
                # tip
                QtGui.QToolTip.showText(helpEvent.globalPos(),
                        self.shapeItems[index].toolTip())
            else:
                QtGui.QToolTip.hideText()
                event.ignore()

            return True
        # We need to call the parent class super so that other event
        # handlers like mouseMoveEvent , mousePressEvent are called by
        # the parent QWidget class
        return super(SortingBox, self).event(event)

    def resizeEvent(self, event):
        """
        This handler manages the resizing of the widget when the user
        tires to resize it.
        """
        margin = self.style().pixelMetric(QtGui.QStyle.PM_DefaultTopLevelMargin)
        x = self.width() - margin
        y = self.height() - margin

    def paintEvent(self, event):
        """
        This handler manages the painting of the Widget.
	The basic operation is to visit all the items in the shapeItems list and draw each one of them
        """
        painter = QtGui.QPainter(self)
        painter.setRenderHint(QtGui.QPainter.Antialiasing)
        for shapeItem in self.shapeItems:
            painter.translate(shapeItem.position())
            painter.setBrush(shapeItem.color())
            painter.drawPath(shapeItem.path())
            painter.translate(-shapeItem.position())

    def mousePressEvent(self, event):
        """
        This handler gets invoked during mouse button press. It checks if
        there is a shape item at the position of the mouse click. If
        there is an item, it assigns the itemInMotion variable with
        its reference.
	"""
        if event.button() == QtCore.Qt.LeftButton:
            index = self.itemAt(event.pos())
            if index != -1:
                self.itemInMotion = self.shapeItems[index]
                self.previousPosition = event.pos()

                value = self.shapeItems[index]
                del self.shapeItems[index]
                self.shapeItems.insert(len(self.shapeItems) - 1, value)

                self.update()

    def mouseMoveEvent(self, event):
        """
        This handler gets invoked whenever the mouse is moved. In this
        example, the itemInMotion is redrawn across the path the mouse
        is moved across.
        """
        if (event.buttons() & QtCore.Qt.LeftButton) and self.itemInMotion:
            self.moveItemTo(event.pos())

    def mouseReleaseEvent(self, event):
        """
        This handler gets invoked whenever the mouse button is
        released. The itemInMotion ShapeItem is drawn to the final
        position as reported by this handler. The itemInMotion is set
        to None
        """
        if (event.button() == QtCore.Qt.LeftButton) and self.itemInMotion:
            self.moveItemTo(event.pos())
            self.itemInMotion = None

    def itemAt(self, pos):
        """
        This method checks if there is an item at a given position.
        It does this by calling the contains object of the
        QPainterPath object. If the pos refers to a point in the item
        a true is returned.
        """
        for i in range(len(self.shapeItems) - 1, -1, -1):
            item = self.shapeItems[i]
            if item.path().contains(QtCore.QPointF(pos - item.position())):
                return i

        return -1

    def moveItemTo(self, pos):
        """
        This method helps to draw the itemOnMotion to a new position
        specified by pos
        """
        offset = pos - self.previousPosition
        self.itemInMotion.setPosition(self.itemInMotion.position() + offset)
        self.previousPosition = QtCore.QPoint(pos)
        self.update()


    def createShapeItem(self, path, toolTip, pos, color):
        """
        This method creates a ShapeItem object for each QPainterPath
        objects and appends them to the shapeItems list
        """
        shapeItem = ShapeItem()
        shapeItem.setPath(path)
        shapeItem.setToolTip(toolTip)
        shapeItem.setPosition(pos)
        shapeItem.setColor(color)
        self.shapeItems.append(shapeItem)
        self.update()

    def initialItemPosition(self, path):
        """
        This method sets the initial item position
        """
        y = (self.height() - path.controlPointRect().height()) / 2

        if len(self.shapeItems) == 0:
            x = ((3 * self.width()) / 2 - path.controlPointRect().width()) / 2
        else:
            x = (self.width() / len(self.shapeItems) - path.controlPointRect().width()) / 2

        return QtCore.QPoint(x, y)


    def initialItemColor(self):
        """
        This method sets the initial item color
        """
        hue = ((len(self.shapeItems) + 1) * 85) % 256
        return QtGui.QColor.fromHsv(hue, 255, 190)



if __name__ == "__main__":

    import sys

    app = QtGui.QApplication(sys.argv)
    # Create an instance of the SortingBox class
    sortingBox = SortingBox()
    sortingBox.show()
    sys.exit(app.exec_())
