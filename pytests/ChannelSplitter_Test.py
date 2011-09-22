#Testing Channel Splitting with Hyperstack. 

from ij.plugin.filter import RGBStackSplitter
from ij.plugin import HyperStackReducer
#ImageStack

def lsmChannelSplitter(imp):
	width = imp.getWidth()
	height = imp.getHeight()
	channels = imp.getNChannels()
	slices = imp.getNSlices()
	frames = imp.getNFrames()
	bitDepth = imp.getBitDepth()
	size = slices*frames
	reducer = HyperStackReducer(imp)
	for ch in range(channels):
		c = ch + 1
		stack2 = ImageStack(width, height, size)
		stack2.setPixels(imp.getProcessor().getPixels(), 1)
		newtitile = "C%d-%s" % (c, imp.getTitle())
		imp2 = ImagePlus(newtitile, stack2)
		#stack2.setPixels(null, 1)
		imp.setPosition(c, 1, 1)
		imp2.setDimensions(1, slices, frames)
		imp2.setCalibration(imp.getCalibration())
		reducer.reduce(imp2);
		if imp2.getNDimensions()>3:
			imp2.setOpenAsHyperStack(true)
			imp2.show()
	imp.changes = false
	imp.close()

def lsmChannelExtractrer(imp, extch):
	width = imp.getWidth()
	height = imp.getHeight()
	channels = imp.getNChannels()
	slices = imp.getNSlices()
	frames = imp.getNFrames()
	bitDepth = imp.getBitDepth()
	size = slices*frames
	reducer = HyperStackReducer(imp)
	if extch > channels:
		return 0
	else:
		c = extch
		imp.setPosition(c, 1, 1)
		stack2 = ImageStack(width, height, size)
		stack2.setPixels(imp.getProcessor().getPixels(), 1)
		newtitile = "C%d-%s" % (c, imp.getTitle())
		imp2 = ImagePlus(newtitile, stack2)
		#stack2.setPixels(null, 1)
		imp.setPosition(c, 1, 1)
		imp2.setDimensions(1, slices, frames)
		imp2.setCalibration(imp.getCalibration())
		reducer.reduce(imp2);
		if imp2.getNDimensions()>3:
			imp2.setOpenAsHyperStack(true)
		imp.changes = False
		return imp2




#imp = IJ.openImage('D:\\People\\Mayumi\\101201\\Nnf1_scsi_4.lsm')
if __name__ == "__main__":
	imp = IJ.getImage()
	#lsmChannelSplitter(imp)
	imp1 = lsmChannelExtractrer(imp, 1)
	imp2 = lsmChannelExtractrer(imp, 2)
	imp3 = lsmChannelExtractrer(imp, 3)
	imp1.show()
	imp2.show()
	imp3.show()
	imp.close()
