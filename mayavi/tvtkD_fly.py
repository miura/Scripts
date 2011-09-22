from tvtk.api import tvtk
import numpy as np

#a = np.random.random((10, 10, 10))

import tifffile as tff
tiffimg = tff.TIFFfile('D:/examples/flybrain3DG.tif')
a = tiffimg.asarray()

i = tvtk.ImageData(spacing=(1, 1, 1.5), origin=(0, 0, 0))
i.point_data.scalars = a.ravel()
i.point_data.scalars.name = 'scalars'
i.dimensions = a.shape
from mayavi import mlab
mlab.pipeline.volume(i)
