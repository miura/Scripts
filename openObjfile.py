# for importing .obj (wavefront) file

from mayavi import mlab
import tkFileDialog

fn = tkFileDialog.askopenfilename()
obj = mlab.pipeline.open(fn)
sur = mlab.pipeline.surface(obj)
mlab.show()

