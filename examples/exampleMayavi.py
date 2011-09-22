# exampleMayavi.py
# Kota Miura (miura@embl.de)

#example script to load coordinates data from tab-delimited file
#and plot in 3D using mayavi2.
#We assume that data in the file has a pair pf coordinates per line,
#so 6 numbers are in one line separated by tab.

from matplotlib import mlab as matp
filename = '/Users/miura/data.txt'
x1, y1, z1, x2, y2, z2 = matp.load(filename, usecols=[0, 1, 2, 3, 4, 5], unpack=True)

from mayavi.mlab import points3d
from mayavi.mlab import plot3d
from mayavi import mlab as maya

p1s = points3d(x1, y1, z1, scale_factor=.25, color=(0, 1, 1))
p2s = points3d(x2, y2, z2, scale_factor=.25, color=(1, 0, 0))

for idx, xval in enumerate(x1):
    plin1 = plot3d([x1[idx], x2[idx]], [y1[idx], y2[idx]], [z1[idx], z2[idx]], tube_radius=0.1, colormap='Spectral', color=(0, 0, 1))
maya.show()
