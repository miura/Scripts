
from mayavi import mlab
import sys
sys.path.append('C:\\python26\\Scripts')
import tifffile as tff
import tkFileDialog

fn = tkFileDialog.askopenfilename()
tiffimg = tff.TIFFfile(fn)

imgarray = tiffimg.asarray()
sc =mlab.pipeline.scalar_field(imgarray)
sc.spacing = [2, 1, 1]
sc.update_image_data = True
#imgw = mlab.pipeline.iso_surface(sc, contours=[imgarray.min()+0.1*imgarray.ptp(),],  opacity=0.3)
imgw = mlab.pipeline.iso_surface(sc, contours=[imgarray.min()+0.1*imgarray.ptp(),],  opacity=1.0)
mlab.show()
