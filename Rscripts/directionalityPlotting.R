#incpath <- "Z:/likun/e2cell2/testinc.csv"
incpath <- "Z:/likun/e1cell1/inc.csv"
incangles <- read.csv(incpath, sep="\t")
#decpath <- "Z:/likun/e2cell2/testdec.csv"
decpath <- "Z:/likun/e1cell1/dec.csv"
decangles <- read.csv(decpath, sep="\t")
hs <-dpih(decangles[,2])
bins <- seq(-pi, pi+hs, by=hs)
histoInc = hist(incangles[,2], breaks=bins, main = "Protrusion Direction", xlab="direction (raidan)")
histoDec = hist(decangles[,2], breaks=bins, main = "Retraction Direction", xlab="direction (raidan)")

