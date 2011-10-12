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
#filename = '/Users/miura/Dropbox/Pairs_NowCorrectDot.txt'
filename = 'c:/dropbox/My Dropbox/Wani_3D/Pairs_NowCorrectDot.txt'
x1, y1, z1, x2, y2, z2 = matp.load(filename, usecols=[0, 1, 2, 3, 4, 5], unpack=True)
#for d in z1:
  #print d
#print x1[0]+x1[2]
#dotsfile = '/Users/miura/Dropbox/ProfileDiscdata.txt'
dotsfile = 'c:/dropbox/My Dropbox/Wani_3D/ProfileDiscdata.txt'
dx1, dy1, dz1 = matp.load(dotsfile, usecols=[0,1,2], unpack=True)
tabledots = matp.load(dotsfile)
xc1 = tabledots[0:(len(tabledots)/2 - 1), 0]
xc2 = tabledots[(len(tabledots)/2):, 0]
yc1 = tabledots[0:(len(tabledots)/2 - 1), 1]
yc2 = tabledots[(len(tabledots)/2):, 1]
zc1 = tabledots[0:(len(tabledots)/2 - 1), 2]
zc2 = tabledots[(len(tabledots)/2):, 2]

from mayavi.mlab import points3d
from mayavi.mlab import plot3d
from mayavi import mlab as maya

p1s = points3d(x1, y1, z1, scale_factor=.25, color=(0, 1, 1))
p2s = points3d(x2, y2, z2, scale_factor=.25, color=(1, 0, 0))
#discdots = points3d(dx1, dy1, dz1, scale_factor=.03, color=(0, 0, 1))
discdots1 = points3d(xc1, yc1, zc1, scale_factor=.03, color=(0, 0, 1))
discdots2 = points3d(xc2, yc2, zc2, scale_factor=.03, color=(0, 0, 1))

#for idx, xval in enumerate(x1):
    #plin1 = plot3d([x1[idx], x2[idx]], [y1[idx], y2[idx]], [z1[idx], z2[idx]], tube_radius=0.1, colormap='Spectral', color=(0, 0, 1))
maya.show()
