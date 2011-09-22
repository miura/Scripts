import cv2 as cv

img = cv.imread("d:/examples/blobs.tif")

import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import numpy as np

#img=mpimg.imread('/Users/miura/img/blobs.tif')

# numpy array to CV matrix
#cvmat = cv.fromarray(img)

#cvmat  to numpyarray is
a = np.asarray(img)
#cv.imshow("blob",img)
#cv.DestroyAllWindows()


imgplot = plt.imshow(a)


