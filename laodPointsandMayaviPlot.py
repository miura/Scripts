#import csv
# data = csv.reader(open('C:/dropbox/My Dropbox/Pairs_NowCorrectDot.txt', 'rb'), delimiter='\t')
#data = csv.reader(open('/Users/miura/Dropbox/Mette/Tracks.csv'))

#p1 = []
#tA = []
#for row, points in enumerate(data):
#    tA.append(points[2])
#    p1.append(points[3:6])
#    p2.append(points[3:])
#for d in tA:
#    print d

from matplotlib import mlab as matp

filename = 'c:/dropbox/My Dropbox/Wani_3D/Pairs_NowCorrectDot.txt'
filename = '/Users/miura/Dropbox/Mette/Tracks.csv'
ind, trajID, tA, x1, y1, z1, ptID = matp.load(filename, skiprows=1, delimiter=',', usecols=[0, 1, 2, 3, 4, 5, 6], unpack=True)

#for d in tA:
#    print d

from mayavi.mlab import points3d
from mayavi.mlab import plot3d
from mayavi import mlab as maya

p1s = points3d(x1, y1, z1, scale_factor=.25, color=(0, 1, 1))

curtid = -1.0
cx = []
cy = []
cz = []
for row, tid in trajID:
    if curtid != tid:
        if len(cx) > 1:
            plot3d(cx, cy, cz, color=(0, 1, 1))
        cx = []
        cy = []
        cz = []
    cx.append(x1[row])
    cy.append(y1[row])
    cz.append(z1[row])


maya.show()

