
filename = '/Users/miura/Dropbox/Mette/vecout.csv'
from mayavi.mlab import quiver3d
#from mayavi.mlab import flow
from mayavi import mlab as maya

tgx = [0, 1, 2, 4]
tgy = [0, -1, 2, -4]
tgz = [0, 1, 2, 4]

tvx = [0.5, 0.1, -0.2, -0.4]
tvy = [0, -0.5, 0.2, -0.4]
tvz = [0.5, -0.5, -0.5, 1]
frame = [22, 21, 20, 0]
coltup = [(1, 1, 1), (1, 0, 0), (0, 0, 1), (0, 1, 0)]
colorlist = []
for row in range(len(tgx)):
    if frame[row] is not 0:
      tup = (frame[row]/22, 0, 1 - frame[row]/22)
      colorlist.append(tup)
    else:
      tup = (0, 0, 0)
      colorlist.append(tup)
#quiver3d( tgx, tgy, tgz, tvx, tvy, tvz, colormap='copper', opacity=0.3, mode='2darrow', scale_factor=1)
for row in range(3):
    quiver3d( tgx[row], tgy[row], tgz[row], tvx[row], tvy[row], tvz[row], color=colorlist[row], opacity=0.3, mode='2darrow', scale_factor=1)
##flow(px, py, pz, vx, vy, vz, color=(0, 1, 1), opacity=0.7 )
maya.show()
