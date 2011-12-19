#3D plotting of the output of Dotlinker 3D (volocity output processing version)
# vector to mlab.flow plot. diverged from simple plotting of tracks. 
#20111202
#20111219 diverged
#Kota Miura (miura@embl.de)

#filename = '/Users/miura/Dropbox/Mette/Tracks.csv'
filename = '/Users/miura/Dropbox/Mette/vecout.csv'
filename = '/Users/miura/Dropbox/Mette/vecout27h1.csv'
filename = 'c:/dropbox/My Dropbox/Mette/vecout.csv'
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

ind, frame, gx, gy, gz, ux, vy, wz = matp.load(filename, skiprows=1, delimiter=',', usecols=[0, 1, 2, 3, 4, 5, 6, 7], unpack=True)

#for d in frame:
    #print d

#from mayavi.mlab import points3d
#from mayavi.mlab import plot3d
from mayavi.mlab import quiver3d
from mayavi.mlab import flow
from mayavi import mlab as maya
import numpy as np

##p1s = points3d(sx, sy, sz, scale_factor=.45, color=(1, 0, 0))

#trial with colorlist 
colorlist = []
      
for row in range(len(frame)):
    if frame[row] is not 0:
      tup = (frame[row]/22, 0.3, 1 - frame[row]/22)
      colorlist.append(tup)
    else:
      tup = (0, 0.3, 0)
      colorlist.append(tup)
# here there should be constructing grid and assign vectors to each. 
x, y, z = np.mgrid[0:max(gx)+10, 0:max(gy)+10, 0:max(gz)+10]

# then loop the vectors, place them in the right positions, then flow can be generated. 

u = np.zeros((x.shape[0], x.shape[1], x.shape[2]))
v = np.zeros((x.shape[0], x.shape[1], x.shape[2]))
w = np.zeros((x.shape[0], x.shape[1], x.shape[2]))
un = np.zeros((x.shape[0], x.shape[1], x.shape[2]))
vn = np.zeros((x.shape[0], x.shape[1], x.shape[2]))
wn = np.zeros((x.shape[0], x.shape[1], x.shape[2]))
for i in zip(gx, gy, gz, ux, vy, wz):
  u[round(i[0]), round(i[1]), round(i[2])] += i[3]
  v[round(i[0]), round(i[1]), round(i[2])] += i[4]
  w[round(i[0]), round(i[1]), round(i[2])] += i[5]
  un[round(i[0]), round(i[1]), round(i[2])] += 1
  vn[round(i[0]), round(i[1]), round(i[2])] += 1
  wn[round(i[0]), round(i[1]), round(i[2])] += 1

unn = np.divide(u, un)
vnn = np.divide(v, vn)
wnn = np.divide(w, wn)
nanpos = np.isnan(unn)
unn[nanpos] = 0.0
nanpos = np.isnan(vnn)
vnn[nanpos] = 0.0
nanpos = np.isnan(wnn)
wnn[nanpos] = 0.0

#quiver3d( x, y, z, unn, vnn, wnn)# colormap='copper', opacity=0.3, mode='2darrow', scale_factor=1)

flow(x, y, z, unn, vnn, wnn)#, color=(0, 1, 1), opacity=0.7 )

#quiver3d(px, py, pz, vx, vy, vz, color=(0, 1, 1), opacity=0.3, mode='2darrow', scale_factor=1)

#quiver3d( gx, gy, gz, ux, vy, wz, colormap='copper', opacity=0.3, mode='2darrow', scale_factor=1)

#for row in range(len(frame)):
#  quiver3d( gx[row], gy[row], gz[row], ux[row], vy[row], wz[row], color=colorlist[row], opacity=1, mode='2darrow', scale_factor=1, line_width=4 )

#quiver3d( gx, gy, gz, ux, vy, wz, colormap='copper', opacity=0.3, mode='2darrow', scale_factor=1)
maya.show()

