#import csv
#data = csv.reader(open('C:/dropbox/My Dropbox/Pairs_NowCorrectDot.txt', 'rb'), delimiter='\t')

#p1 = []
#p2 = []
#for row, points in enumerate(data):
#    p1.append(points[:3])
#    p2.append(points[3:])
#for d in p2:
#print d

from matplotlib import mlab as matp
filename = 'c:/dropbox/My Dropbox/Pairs_NowCorrectDot.txt'
x1, y1, z1, x2, y2, z2 = matp.load(filename, usecols=[0, 1, 2, 3, 4, 5], unpack=True)
#for d in z1:
  #print d
#print x1[0]+x1[2]

from mayavi.mlab import points3d
from mayavi.mlab import plot3d
from mayavi import mlab as maya

p1s = points3d(x1, y1, z1, scale_factor=.25, color=(0, 1, 1))
p2s = points3d(x2, y2, z2, scale_factor=.25, color=(1, 0, 0))

for idx, xval in enumerate(x1):
    plin1 = plot3d([x1[idx], x2[idx]], [y1[idx], y2[idx]], [z1[idx], z2[idx]], tube_radius=0.1, colormap='Spectral', color=(0, 0, 1))
maya.show()
