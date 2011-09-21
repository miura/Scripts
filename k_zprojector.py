# Parses image files in separate folders

from java.io import File as JFile

def createStackImp(imp):
	ims = ImageStack(imp.getWidth(), imp.getHeight())
	ims.addSlice("0", imp.getProcessor())
	simp = ImagePlus("2D", ims)
	return simp

def importAChannle(path, chstr):
	dir = JFile(path)
	filesA = dir.list()
	sp = JFile.separator
	filesL = filesA.tolist()
	filesL.sort()
	simp = None
	for idx, i in enumerate(filesL):
		if i.startswith("._") != 1:
			if i.find(chstr) > -1:
#				IJ.log(str(idx))
				imp = IJ.openImage(path + sp + i)
#				print str(imp.getWidth())
				if simp == None:
					simp = createStackImp(imp)
				else:
					simp.getStack().addSlice(str(idx), imp.getProcessor())
				print str(idx)+ ": " +  i
	return simp
					


def maxZprojection(stackimp):
	zp = ZProjector(stackimp)
	zp.setMethod(ZProjector.MAX_METHOD)
	zp.doProjection()
	zpimp = zp.getProjection()
	return zpimp

def metaFolders(ppath, chstr):
	dir = JFile(ppath)
	filesA = dir.list()
	sp = JFile.separator
	filesL = filesA.tolist()
	filesL.sort()
	projsimp = None
	for idx, i in enumerate(filesL):
		path = ppath + sp + i
		stackimp = importAChannle(path, chstr)
		zpstackimp = maxZprojection(stackimp)
		if projsimp == None:
			projsimp = createStackImp(zpstackimp):
		else:
			projsimp.getStack().addSlice("T" + str(idx), zpstackimp.getProcessor())
		print "--- TimePoint" + str(idx)+ " max Zprojection added ---"
	return projsimp
		
	
#path = "Z:/likun/10uM rapa 1h_e1 caudal fin/T00001"
ppath = "Z:/likun/10uM rapa 1h_e1 caudal fin"
#path = "D:\\People\\Tina\\20110813\\out";
#path = "Z:\\Tina\\test";
#zpstackimp.show()
chstr = "C01"
zproimp = metaFolders(ppath, chstr)
IJ.saveAs(zproimp, "Tiff", ppath + sp + "zproj"+chstr+".tif")



			
