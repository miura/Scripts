# learning numpy multidimensional array
# http://www.scipy.org/Tentative_NumPy_Tutorial
import numpy as np
x = np.linspace(0, 2*np.pi, 100)
y = np.sin(x)
print "xsize", x.size
print y.size
print x.dtype

#import matplotlib.pyplot as plt
#plt.plot(x, y)
#plt.axis([-1, 7, -2, 2])
#plt.show()

a = np.arange(6)
print a
b = np.arange(12).reshape(4,3)
print b
c = np.arange(24).reshape(2, 3, 4)
print c

A = np.array([[1,1],
             [0,1]])
B = np.array([[2,0],
             [3,4]])
print A*B
print np.dot(A,B)
print np.dot(B,A)
