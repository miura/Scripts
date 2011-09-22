# basic handling of tiff 2D and 3D images
# import tif and convert to numpy array
# then visualize using mayavi2

#import os
import sys
from mayavi import mlab

sys.path.append('/Users/miura/pylib')
import tifffile as tff

#blobs.tif is a 2D sample image
#tiffimg = tff.TIFFfile('D:/examples/blobs.tif')
#tiffimg = tff.TIFFfile('D:/examples/g1f.tif')
tiffimg = tff.TIFFfile('/Users/miura/img/flybrainG.tif')

imgarray = tiffimg.asarray()
sc =mlab.pipeline.scalar_field(imgarray)
sc.spacing = [2, 1, 1]
sc.update_image_data = True
# showing 3D stack image 
imgw = mlab.pipeline.volume(sc) 

