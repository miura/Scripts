#3D plotting of the output of Dotlinker 3D (volocity output processing version)
#20111202
#Kota Miura (miura@embl.de)

filename = 'c:/dropbox/My Dropbox/Mette/vecout.csv'
#filename = '/Users/miura/Dropbox/Mette/Tracks.csv'
filename = '/Users/miura/Dropbox/Mette/vecout.csv'

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
#from mayavi.mlab import flow
from mayavi import mlab as maya

##p1s = points3d(sx, sy, sz, scale_factor=.45, color=(1, 0, 0))

#trial with colorlist 
colorlist = []
#for row in range(len(ind)):
    #if frame[row] is not 0:
      #colorlist.append((frame[row]/22, 0, 1 - frame[row]/22))
    #else
      #colorlist.append(0, 0, 0)
      
for row in range(len(frame)):
    if frame[row] is not 0:
      tup = (frame[row]/22, 0.3, 1 - frame[row]/22)
      colorlist.append(tup)
    else:
      tup = (0, 0.3, 0)
      colorlist.append(tup)
# here there should be constructing grid and assign vectors to each. 
# x, y, z = numpy.mgrid[0:max(gx)+10, 0:max(gy)+10, 0:max(gz)+10]

# then loop the vectors, place them in the right positions, then flow can be generated. 


#curtid = -1.0
#cx = []
#cy = []
#cz = []
##for row, tid in trajID:
##for d in ind:
    ##if (curtid - trajID[d-1]) != 0:
        ##print 'start trajec', trajID[d-1]
        ##if len(cx) > 1:
          ##print 'plotting', curtid, 'length:', len(cx)
          ##plot3d(cx, cy, cz, line_width=14.0, color=(0, 1, 1))
        ##curtid = trajID[d-1]
        ##cx = []
        ##cy = []
        ##cz = []
    ##cx.append(sx[d-1])
    ##cy.append(sy[d-1])
    ##cz.append(sz[d-1])

#vx = []
#vy = []
#vz = []
#px = []
#py = []
#pz = []
#curid = -1.0
#for d in ind:
    #if (curtid - trajID[d-1]) == 0:
        ##print 'in trajec', trajID[d-1]
        #px.append(sx[d-2])
        #py.append(sy[d-2])
        #pz.append(sz[d-2])
        #vx.append(sx[d-1] - sx[d-2])
        #vy.append(sy[d-1] - sy[d-2])
        #vz.append(sz[d-1] - sz[d-2])
    #else:
        #curtid = trajID[d-1]
        #print 'trajectory: ', trajID[d-1]
#quiver3d(px, py, pz, vx, vy, vz, color=(0, 1, 1), opacity=0.3, mode='2darrow', scale_factor=1)
#quiver3d( gx, gy, gz, ux, vy, wz, colormap='copper', opacity=0.3, mode='2darrow', scale_factor=1)
for row in range(len(frame)):
  quiver3d( gx[row], gy[row], gz[row], ux[row], vy[row], wz[row], color=colorlist[row], opacity=1, mode='2darrow', scale_factor=1, line_width=4 )
  #quiver3d( gx[row], gy[row], gz[row], ux[row], vy[row], wz[row], color=colorlist[row], opacity=1, mode='cylinder', scale_factor=1, scale_mode='vector')
#quiver3d( gx, gy, gz, ux, vy, wz, colormap='copper', opacity=0.3, mode='2darrow', scale_factor=1)
##flow(px, py, pz, vx, vy, vz, color=(0, 1, 1), opacity=0.7 )
maya.show()

