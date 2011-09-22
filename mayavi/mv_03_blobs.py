# basic handling of tiff 2D and 3D images
# import tif and convert to numpy array
# then visualize using mayavi2

#import os
#import sys
from mayavi import mlab

#sys.path.append('C:\\dropbox\\My Dropbox\\codes\\python')
import tifffile as tff

#blobs.tif is a 2D sample image
#tiffimg = tff.TIFFfile('D:/examples/blobs.tif')
tiffimg = tff.TIFFfile('D:/examples/g1f.tif')
#tiffimg = tff.TIFFfile('D:\\examples\\flybrain3DG.tif')
#tiffimg = tff.TIFFfile('D:/examples/flybrain3DG.tif')

imgarray = tiffimg.asarray()

# showing 2D array (blobs) as a 2D plot in mayavi. 
imgwin = mlab.imshow(imgarray, colormap="gist_earth")

# showing 3D stack image 
#mlab.pipeline.volume(mlab.pipeline.scalar_field(imgarray))
