# -*- coding: utf-8 -*-
"""
Created on Fri Aug 05 21:00:47 2011

@author: Kota
"""

import numpy as np
x, y, z = np.ogrid[-10:10:20j, -10:10:20j, -10:10:20j]
s = np.sin(x*y*z)/(x*y*z)

from enthought.mayavi import mlab
#mlab.contour3d(s)
mlab.pipeline.volume(mlab.pipeline.scalar_field(s))
mlab.show()