# basic handling of tiff 2D and 3D images
# import tif and convert to numpy array
# then visualize using mayavi2

# with this example, showing two contours. One at the high intensity and the other at the low intensity. 

#import os
#import sys
from mayavi import mlab

#sys.path.append('C:\\dropbox\\My Dropbox\\codes\\python')
import tifffile as tff

#blobs.tif is a 2D sample image
#tiffimg = tff.TIFFfile('D:/examples/blobs.tif')
#tiffimg = tff.TIFFfile('D:/examples/g1f.tif')
tiffimg = tff.TIFFfile('D:/examples/flybrain3DG.tif')
tiffimg2 = tff.TIFFfile('D:/examples/flybrain3DR.tif')

imgarray = tiffimg.asarray()
imgarray2 = tiffimg2.asarray()

sc =mlab.pipeline.scalar_field(imgarray)
sc2 =mlab.pipeline.scalar_field(imgarray2)
sc.spacing = [2, 1, 1]
sc2.spacing = [2, 1, 1]
sc.update_image_data = True
sc2.update_image_data = True
# showing 3D stack image 
##imgw = mlab.pipeline.volume(sc)
#imgw2 = mlab.pipeline.volume(sc2)
imgw = mlab.pipeline.iso_surface(sc, contours=[imgarray.min()+0.1*imgarray.ptp(),],  opacity=0.3)
imgw = mlab.pipeline.iso_surface(sc, contours=[imgarray.max()-0.1*imgarray.ptp(), ],)
# setting color transfer function
from tvtk.util.ctf import ColorTransferFunction
#ctf = ColorTransferFunction()
#ctf.add_rgb_point(0.0, 0.0, 0.0, 0.0)
#ctf.add_rgb_point(255.0, 1.0, 0.0, 0.0)
#imgw._volume_property.set_color(ctf)
#imgw._ctf = ctf
#imgw.update_ctf = True
#
## Changing the otf:
from tvtk.util.ctf import PiecewiseFunction
#otf = PiecewiseFunction()
#otf.add_point(200, 0.0)
#otf.add_point(255, 0.2)
#imgw._otf = otf
#imgw._volume_property.set_scalar_opacity(otf)

## setting color transfer function
#ctf2 = ColorTransferFunction()
#ctf2.add_rgb_point(0.0, 0.0, 0.0, 0.0)
#ctf2.add_rgb_point(255.0, 0.0, 1.0, 0.0)
#imgw2._volume_property.set_color(ctf2)
#imgw2._ctf = ctf2
#imgw2.update_ctf = True

## Changing the otf:
#otf2 = PiecewiseFunction()
#otf2.add_point(100, 0.0)
#otf2.add_point(255, 1.0)
#imgw2._otf = otf2
#imgw2._volume_property.set_scalar_opacity(otf2)

mlab.show()
