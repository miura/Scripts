#!/usr/bin/python

# tetris.py 
# 
# Note that the original form of this code was taken from a public
# PyQt tutorial website and heavily modified to illustrate use of
# different widget and frame types. In addition, the comments present
# were added to the best of our ability. Apologies to the original
# author if we mis-represented any aspects of the original code.
# original form can be found at:
#
# http://zetcode.com/tutorials/pyqt4/thetetrisgame
#


import sys
import random
from PyQt4 import QtCore, QtGui

###################################################################
###################################################################
# Create a NewTop class that is derived from the basic QtGui.GroupBox
# Class. This will create a widget context in which we can effect the
# layout of the things it contains, therefor we can arrange things as
# we wish. Other examples use a QDialog box as the top level widget
# because its easier for demo purposes. Still other examples use the
# QMainWindow which is a standard framework for GUI based commands but
# is heavier weight than seemed appropriate for this example.
#
class NewTop(QtGui.QGroupBox):
    def __init__(self, application, parent=None):
        super(NewTop, self).__init__(parent)

        self.setWindowTitle('Tetris')

	# Create a frame which will be used to highlight the
	# bounderies of the board. Make the frame border five pixels
	# wide and give it a raised edge.
	#
        self.board_frame = QtGui.QFrame(self)
        self.board_frame.setLineWidth(5)
        self.board_frame.setFrameShape(QtGui.QFrame.Box)
        self.board_frame.setFrameShadow(QtGui.QFrame.Raised)

        # Create a layout object to contain the board. Note in this
        # case it does not matter whether we use a VBox or an HBox
        # because we are inserting only a single widget. 
        #
        # Create and insert the board into the layout and associate
        # the layout with the board frame. Note that we pass in the
        # frame as the parent widget of the board.
        #
        board_frame_layout = QtGui.QVBoxLayout()
	self.tetris_board = Board(self.board_frame)
        board_frame_layout.addWidget(self.tetris_board)
        self.board_frame.setLayout(board_frame_layout)

	# Create a frame which will be used to highlight the
	# bounderies of the scorecard.  Make the frame border one
	# pixel wide and give it a raised edge.
	#
        self.card_frame = QtGui.QFrame(self)
        self.card_frame.setLineWidth(1)
        self.card_frame.setFrameShape(QtGui.QFrame.Box)
        self.card_frame.setFrameShadow(QtGui.QFrame.Raised)

        self.card_frame.setMinimumHeight(30)
        self.card_frame.setMaximumHeight(30)

        # CLUE CLUE CLUE CLUE CLUE CLUE CLUE Create a layout object to
        # contain the score card. Note in this case it does not matter
        # that we use a VBox or an HBox because we are inserting only
        # a single widget. However, we use an HBox because we believe
        # this is the frame in which you will want to insert your new
        # widget.
        #
        # Create and insert the score card into the layout and
        # associate the layout with the card frame. Note that we pass
        # in the frame as the parent widget of the score card.
        #
        card_frame_layout = QtGui.QHBoxLayout()
	self.score_card = ScoreCard(self.card_frame)
        card_frame_layout.addWidget(self.score_card)
        self.card_frame.setLayout(card_frame_layout)

        # Create a Vertical layout box which we will associate with
        # the top level widget. Into that we add, from top to bottom,
        # the frame containing the board and the frame containing the
        # score card.
        #
        layout = QtGui.QVBoxLayout()
        layout.addWidget(self.board_frame)
	layout.addWidget(self.card_frame)
        self.setLayout(layout)

        # CLUE CLUE CLUE
	# Connect the messageToScoreCard signal emitted by the board
	# when a line is cleared to the showMessage slot of the score
	# card widget. Note that the board only knows that it should
	# emit a signal containing a string representing the number of
	# lines cleared whenever that number changes. Similarly, the
	# score card only knows that it should change its text when
	# its showMessage method is invoked. This call to connect()
	# associates the signal emitted by the board with the
	# showMessage() method of the score card. The call is made
	# here because this widget created both the board and the
	# score card, and thus has references to both. This
	# association of the signal to the slot is what makes the
	# score card label display the number of lines cleared.
	#
	self.connect(self.tetris_board, QtCore.SIGNAL("messageToScoreCard(QString)"), 
	    self.score_card.showMessage)

	# Before exiting this method it is important to call the
	# start() method of the board because it starts the periodic
	# timer that drives the piece movement within the boundaries
	# of the board.
	#
	self.tetris_board.start()

	# Set the window location and size before showing The first
        # two values are the X and Y coordinates of the application
        # window relative to the top left corner of the screen, and
        # the second pair are the width and height of the application
        # window.
	#
        self.setGeometry(300, 300, 180, 360)

###################################################################
###################################################################
# This Class exists solely to illustrate how to create a custom SLOT
# which can then be connected to the signal generated when a line is
# cleared. The custom signal is named "messageToScoreCard"
#
class ScoreCard(QtGui.QLabel):
    def __init__(self, parent):
        super(ScoreCard, self).__init__(parent)

    # This is the method connected to the signal emitted by the Board
    #
    # ADVICE ADVICE ADVICE It would be prudent to search in this file
    # for all used of "showMessage" to find where a signal is being
    # connected to this slot
    #
    def showMessage(self, message):
        self.setText(message)

###################################################################
###################################################################
# This is the class which creates the tetris board. Note that it also
# creates the periodic timer which drives piece movement within the
# game. Also, it emits the "messageToScoreCard" signal.
#
#
class Board(QtGui.QFrame):
    # These are the board dimensions in tetris-block units
    #
    BoardWidth = 10
    BoardHeight = 22

    # This is the period in milliseconds at which board updates occur
    #
    Speed = 300
    
    # These are the messages that are passed at the beginning and end
    # of the game, as well as when the user pauses. They are displayed
    # in the score card instead of the line cleared count.
    #
    InitMessage   = "Welcome to Tetris!"
    PausedMessage = "Paused"
    ExitMessage   = "Game Over"

    # This is the initialization routine for the board.
    #
    def __init__(self, parent):
        QtGui.QFrame.__init__(self, parent)
        
        # This creates the timer object, but does not start it, that
        # will drive board updates.
        #
        self.timer = QtCore.QBasicTimer()

        # Here we create the current and next Shape to be used on the
        # game board which fills initial pipeline. Each successive
        # shape will be created in the normal context.
        self.curPiece = Shape()
        self.nextPiece = Shape()
        self.nextPiece.setRandomShape()

        # We initialize the X and Y coordinates of the current
        # Shape. We guess that these are in board coordinates, but we
        # are not really sure.
        #
        self.curX = 0
        self.curY = 0

        # We initialize the number of lines removed and the empty
        # board.
        #
        self.numLinesRemoved = 0
        self.board = []
        self.clearBoard()

        # This is associated with the keyboard focus which determines
        # where keyboard and mouse events are delivered.
        #
        self.setFocusPolicy(QtCore.Qt.StrongFocus)

        # Initialize basic state variables
        #
        self.isStarted = False
        self.isPaused = False

        # No idea.
        #
        self.isWaitingAfterLine = False

    # The next four routines we express no opinion about.
    #
    def shapeAt(self, x, y):
        return self.board[(y * Board.BoardWidth) + x]

    def setShapeAt(self, x, y, shape):
        self.board[(y * Board.BoardWidth) + x] = shape

    def squareWidth(self):
        return self.contentsRect().width() / Board.BoardWidth

    def squareHeight(self):
        return self.contentsRect().height() / Board.BoardHeight

    # The start() method starts the timer driven board behavior.
    #
    def start(self):
        if self.isPaused:
            return

        # Here we set state variables to reflect that play has
        # begun. Note that we also reset the number of lines removed
        # and reclear the play board. This routine is being extra
        # cautious and making as few assumptions as possible about its
        # calling context.
        #
        self.isStarted = True
        self.isWaitingAfterLine = False
        self.numLinesRemoved = 0
        self.clearBoard()

        # Here we are emitting a message to the score card welcoming
        # players to the game
        #
        self.emit(QtCore.SIGNAL("messageToScoreCard(QString)"), 
	    self.InitMessage)

        # Here we grab a new piece for the next iteration of play.
        #
        self.newPiece()

        # Here we start the timer which will drive gameplay.
        #
        self.timer.start(Board.Speed, self)

    # This method is invoke whenever the timer goes off by definition
    # of QBasicTimer. Remember that self.timer is an instance of
    # QBasicTimer.
    #
    def timerEvent(self, event):
        # Check to see if it is the timer that the board defined.
        #
        if event.timerId() == self.timer.timerId():
            # When the timer goes off, the board needs to be updated.
            #
            if self.isWaitingAfterLine:
                self.isWaitingAfterLine = False
                self.newPiece()
            else:
                self.oneLineDown()
        else:
            # Otherwise, call the parent's timer handler
            #
            QtGui.QFrame.timerEvent(self, event)

    # Method called when a player pauses the game
    #
    def pause(self):
        if not self.isStarted:
            return

        self.isPaused = not self.isPaused
        if self.isPaused:
            self.timer.stop()
            self.emit(QtCore.SIGNAL("messageToScoreCard(QString)"), 
	        self.PausedMessage)
        else:
            self.timer.start(Board.Speed, self)
            self.emit(QtCore.SIGNAL("messageToScoreCard(QString)"), 
	        str(self.numLinesRemoved))

        self.update()

    # Called by the Qt environment whenever the board needs to be
    # repainted. One of the reasons for this is when a widget's
    # update() method is invoked. The association between the update()
    # and paintEvent() is implicit in the Qt semantics.
    #
    def paintEvent(self, event):
        # Get a handle to the board's painter.
        #
        painter = QtGui.QPainter(self)
        rect = self.contentsRect()

        boardTop = rect.bottom() - Board.BoardHeight * self.squareHeight()

        # This loop draws all of the squares that are not moving.
        #
        for i in range(Board.BoardHeight):
            for j in range(Board.BoardWidth):
                shape = self.shapeAt(j, Board.BoardHeight - i - 1)
                if shape != Tetrominoes.NoShape:
                    self.drawSquare(painter,
                        rect.left() + j * self.squareWidth(),
                        boardTop + i * self.squareHeight(), shape)

        # This code draws the moving shape as long as it is not 'NoShape'
        #
        if self.curPiece.shape() != Tetrominoes.NoShape:
            for i in range(4):
                x = self.curX + self.curPiece.x(i)
                y = self.curY - self.curPiece.y(i)
                self.drawSquare(painter, rect.left() + x * self.squareWidth(),
                    boardTop + (Board.BoardHeight - y - 1) * self.squareHeight(),
                    self.curPiece.shape())

    # This method will be called whenever a key event occurs. Note
    # that this is the only keyPressEvent() method defined and if we
    # defined one for other widgets, confusion and consternation might
    # ensue.
    #
    def keyPressEvent(self, event):
        if not self.isStarted or self.curPiece.shape() == Tetrominoes.NoShape:
            QtGui.QWidget.keyPressEvent(self, event)
            return

        # First find out which key was pressed, and then take
        # tetris-level actions for all of the keys we care about,
        # otherwise pass the key event to our parent.
        #
        key = event.key()
	if key == QtCore.Qt.Key_P:
	    self.pause()
            return
	if self.isPaused:
            return
        elif key == QtCore.Qt.Key_Left:
            self.tryMove(self.curPiece, self.curX - 1, self.curY)
        elif key == QtCore.Qt.Key_Right:
            self.tryMove(self.curPiece, self.curX + 1, self.curY)
        elif key == QtCore.Qt.Key_Down:
            self.tryMove(self.curPiece.rotatedRight(), self.curX, self.curY)
        elif key == QtCore.Qt.Key_Up:
            self.tryMove(self.curPiece.rotatedLeft(), self.curX, self.curY)
        elif key == QtCore.Qt.Key_Space:
            self.dropDown()
        elif key == QtCore.Qt.Key_D:
            self.oneLineDown()
        else:
            QtGui.QWidget.keyPressEvent(self, event)


    def clearBoard(self):
        for i in range(Board.BoardHeight * Board.BoardWidth):
	    self.board.append(Tetrominoes.NoShape)

    # Drop down drops a shape immediately down to the bottom
    #
    def dropDown(self):
        newY = self.curY
        while newY > 0:
            if not self.tryMove(self.curPiece, self.curX, newY - 1):
                break
            newY -= 1

        self.pieceDropped()

    # Moves the current piece one line down
    #
    def oneLineDown(self):
        if not self.tryMove(self.curPiece, self.curX, self.curY - 1):
            self.pieceDropped()

    # Called when a piece reaches the bottom of the board
    #
    def pieceDropped(self):
        for i in range(4):
            x = self.curX + self.curPiece.x(i)
            y = self.curY - self.curPiece.y(i)
            self.setShapeAt(x, y, self.curPiece.shape())

        # Check for any full lines which may have been created
        #
        self.removeFullLines()

        if not self.isWaitingAfterLine:
            self.newPiece()

    # Detects and then removes any full lines on the board
    #
    def removeFullLines(self):
        numFullLines = 0

	rowsToRemove = []

	for i in range(Board.BoardHeight):
	    n = 0
            for j in range(Board.BoardWidth):
                if not self.shapeAt(j, i) == Tetrominoes.NoShape:
                    n = n + 1

	    if n == 10:
		rowsToRemove.append(i)

	rowsToRemove.reverse()

	for m in rowsToRemove:
	    for k in range(m, Board.BoardHeight):
	        for l in range(Board.BoardWidth):
                    self.setShapeAt(l, k, self.shapeAt(l, k + 1))

        numFullLines = numFullLines + len(rowsToRemove)

        if numFullLines > 0:
            self.numLinesRemoved = self.numLinesRemoved + numFullLines
            self.emit(QtCore.SIGNAL("messageToScoreCard(QString)"), 
		str(self.numLinesRemoved))
            self.isWaitingAfterLine = True
            self.curPiece.setShape(Tetrominoes.NoShape)
            self.update()

    # Generates a new random tetris piece
    #
    def newPiece(self):
        self.curPiece = self.nextPiece
        self.nextPiece.setRandomShape()
        self.curX = Board.BoardWidth / 2 + 1
        self.curY = Board.BoardHeight - 1 + self.curPiece.minY()

        if not self.tryMove(self.curPiece, self.curX, self.curY):
            self.curPiece.setShape(Tetrominoes.NoShape)
            self.timer.stop()
            self.isStarted = False
            self.emit(QtCore.SIGNAL("messageToScoreCard(QString)"),
	        self.ExitMessage)


    # Tries to move the falling piece in response to either a key
    # press or a timer event
    #
    def tryMove(self, newPiece, newX, newY):
        for i in range(4):
            x = newX + newPiece.x(i)
            y = newY - newPiece.y(i)
            if x < 0 or x >= Board.BoardWidth or y < 0 or y >= Board.BoardHeight:
                return False
            if self.shapeAt(x, y) != Tetrominoes.NoShape:
                return False

        self.curPiece = newPiece
        self.curX = newX
        self.curY = newY
        self.update()
        return True

    # Draws the individual squares of a tetris piece and uses the
    # color table to choose the correct color based upon the shape
    # number.
    #
    def drawSquare(self, painter, x, y, shape):
        colorTable = [0x000000, 0xCC6666, 0x66CC66, 0x6666CC,
                      0xCCCC66, 0xCC66CC, 0x66CCCC, 0xDAAA00]

        color = QtGui.QColor(colorTable[shape])
        painter.fillRect(x + 1, y + 1, self.squareWidth() - 2, 
	    self.squareHeight() - 2, color)

        painter.setPen(color.light())
        painter.drawLine(x, y + self.squareHeight() - 1, x, y)
        painter.drawLine(x, y, x + self.squareWidth() - 1, y)

        painter.setPen(color.dark())
        painter.drawLine(x + 1, y + self.squareHeight() - 1,
            x + self.squareWidth() - 1, y + self.squareHeight() - 1)
        painter.drawLine(x + self.squareWidth() - 1, 
	    y + self.squareHeight() - 1, x + self.squareWidth() - 1, y + 1)

###################################################################
###################################################################
# A simple enum listing the standard Tetris block shapes.
#
class Tetrominoes(object):
    NoShape = 0
    ZShape = 1
    SShape = 2
    LineShape = 3
    TShape = 4
    SquareShape = 5
    LShape = 6
    MirroredLShape = 7

###################################################################
###################################################################
# A generic shape class which generates the more specific Tetris block
# shapes and is responsible for translating the abstract description
# of a piece to a particular X and Y coordinate. Beyond this we have
# not really figured out the low level details, but also do not need
# to use the board widget and add to the application as we desire.
#
class Shape(object):
    coordsTable = (
        ((0, 0),     (0, 0),     (0, 0),     (0, 0)),
        ((0, -1),    (0, 0),     (-1, 0),    (-1, 1)),
        ((0, -1),    (0, 0),     (1, 0),     (1, 1)),
        ((0, -1),    (0, 0),     (0, 1),     (0, 2)),
        ((-1, 0),    (0, 0),     (1, 0),     (0, 1)),
        ((0, 0),     (1, 0),     (0, 1),     (1, 1)),
        ((-1, -1),   (0, -1),    (0, 0),     (0, 1)),
        ((1, -1),    (0, -1),    (0, 0),     (0, 1))
    )

    def __init__(self):
        self.coords = [[0,0] for i in range(4)]
        self.pieceShape = Tetrominoes.NoShape

        self.setShape(Tetrominoes.NoShape)

    def shape(self):
        return self.pieceShape

    def setShape(self, shape):
        table = Shape.coordsTable[shape]
        for i in range(4):
            for j in range(2):
                self.coords[i][j] = table[i][j]

        self.pieceShape = shape

    def setRandomShape(self):
        self.setShape(random.randint(1, 7))

    def x(self, index):
        return self.coords[index][0]

    def y(self, index):
        return self.coords[index][1]

    def setX(self, index, x):
        self.coords[index][0] = x

    def setY(self, index, y):
        self.coords[index][1] = y

    def minX(self):
        m = self.coords[0][0]
        for i in range(4):
            m = min(m, self.coords[i][0])

        return m

    def maxX(self):
        m = self.coords[0][0]
        for i in range(4):
            m = max(m, self.coords[i][0])

        return m

    def minY(self):
        m = self.coords[0][1]
        for i in range(4):
            m = min(m, self.coords[i][1])

        return m

    def maxY(self):
        m = self.coords[0][1]
        for i in range(4):
            m = max(m, self.coords[i][1])

        return m

    def rotatedLeft(self):
        if self.pieceShape == Tetrominoes.SquareShape:
            return self

        result = Shape()
        result.pieceShape = self.pieceShape
        for i in range(4):
            result.setX(i, self.y(i))
            result.setY(i, -self.x(i))

        return result

    def rotatedRight(self):
        if self.pieceShape == Tetrominoes.SquareShape:
            return self

        result = Shape()
        result.pieceShape = self.pieceShape
        for i in range(4):
            result.setX(i, -self.y(i))
            result.setY(i, self.x(i))

        return result

###################################################################
###################################################################
# Test to see if this code has been called as a command
#
if __name__ == '__main__':
    # Create an Application framework which will scan the command line
    # arguments for QT related options and leave our sys.argv holding
    # whatever is left over
    #
    app = QtGui.QApplication(sys.argv)
    
    # Create our chosen top level widget and designate the application
    # as its parent. Then cause it to be displayed with the show()
    # method
    #
    # NOTE NOTE NOTE - README README README - NOTE NOTE NOTE:
    #
    # Due to the nature of the GUI event-driven programming model,
    # creating the top level widget for the application causes: all
    # other aspects of the GUI and its subordinate widgets to be
    # created, all relationships such as SLOT and SIGNAL connection to
    # be created, and any background processing such as timers to be
    # started. At that point the GUI application is complete and
    # awaits an event generated by the user. The GUI application will
    # terminate only when the correct event, such as choosing exit
    # from a menu, or clicking the X icon at the upper right of the
    # window, occurs.
    #
    tetris = NewTop(app)
    tetris.show()
    
    # Call the applications exec_() method first and use its return
    # value as the argument to sys.exit(). Note that we reach here
    # only when the Application code exits.
    #
    sys.exit(app.exec_())
