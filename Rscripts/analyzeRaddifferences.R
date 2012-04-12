# analyzeZdifferences.R
#
# searching for "chemoattracting" region within 3D
#
# input: net displacement vectors
# output: clorocoded cell movement bias index.
# 2012 Apr, vector position categorized by radial Zoning
# Kota MIura (miura@embl.de)


upAndLow <- function (refz) {
  filepath = paste(filedir, filehead, refz, '.csv', sep="")
  df <- read.csv(filepath, header=FALSE)
  zlevel <- 8
  uppersum <- sum(df$V9[df$V5 > zlevel])
  lowersum <- sum(df$V9[df$V5 <= zlevel])
  uppertotaldisp <- sum(abs(df$V9[df$V5 > zlevel]))
  lowertotaldisp <- sum(abs(df$V9[df$V5 <= zlevel]))
  uppersumNorm <- uppersum/uppertotaldisp
  lowersumNorm <- lowersum/lowertotaldisp
  cat("Z", refz, "\tupper:", uppersum, "\tLower:", lowersum, '\n')
  cat("Z", refz, "\tupperN:", uppersumNorm, "\tLowerN:", lowersumNorm, '\n')  
  cat(min(df$V5), max(df$V5), '\n')
}

upAndLowV2 <- function (refz, measurethickness) {
  filepath = paste(filedir, filehead, refz, '.csv', sep="")
  df <- read.csv(filepath, header=FALSE)
#  zlevel <- 8
  inc <- measurethickness
#  minz = floor(min(df$V5))
  minz = 0
  maxz = floor(max(df$V5))
  for(zlevel in seq(minz, maxz, by=inc)){

    netsum <- sum(df$V9[((df$V5 >= zlevel) & (df$V5 < (zlevel+inc)))])
    totaldisp <- sum(abs(df$V9[((df$V5 >= zlevel) & (df$V5 < zlevel+inc))]))
    netsumNorm <- netsum/totaldisp
    pointnum <- length(df$V9[((df$V5 >= zlevel) & (df$V5 < zlevel+inc))])
    cat('=== at Z', zlevel, "-", zlevel+inc, "===\n")
    cat('...min:', minz, '\tmax:', maxz, '\n')
    cat("refZ", refz, "\tnet:", netsum, '\n')
    cat("refZ", refz, "\tnetNorm:", netsumNorm, '\n')
    cat("refZ", refz, "\tpoints:", pointnum, '\n')    
    if (zlevel==minz) data <- netsumNorm
    else data <- append(data,netsumNorm)
  }
  return(data)
}

# refz z level of the reference bar. used for composing file name. 
# measure thickness is the height (in case of z slicing) of the zone. 
# in case of radial measurement, this will be the thickness of super ficial layer. 
# 10 micrometer or so?
# spherecenter: 3D coordinates of the sphere center. 
radialZoning <- function (refz, measurethickness, spherecenter) {
  filepath = paste(filedir, filehead, refz, '.csv', sep="")
  df <- read.csv(filepath, header=FALSE)
  inc <- measurethickness
  #  minz = floor(min(df$V5))
  dist2center <- dist3D(df$V3, df$V4, df$V5, spherecenter)
  minz = 0
  maxz = floor(max(dist2center))
  for(raddist in seq(minz, maxz, by=inc)){  
    netsum <- sum(df$V9[((dist3D(df$V3, df$V4, df$V5, spherecenter) >= raddist) & (dist3D(df$V3, df$V4, df$V5, spherecenter) < (raddist+inc)))])
    totaldisp <- sum(abs(df$V9[((dist3D(df$V3, df$V4, df$V5, spherecenter) >= raddist) & (dist3D(df$V3, df$V4, df$V5, spherecenter) < raddist+inc))]))
    netsumNorm <- netsum/totaldisp
    pointnum <- length(df$V9[((dist3D(df$V3, df$V4, df$V5, spherecenter) >= raddist) & (dist3D(df$V3, df$V4, df$V5, spherecenter) < raddist+inc))])
    cat('=== at radial dist', raddist, "-", raddist+inc, "===\n")
    cat('...min:', minz, '\tmax:', maxz, '\n')
    cat("refZ", refz, "\tnet:", netsum, '\n')
    cat("refZ", refz, "\tnetNorm:", netsumNorm, '\n')
    cat("refZ", refz, "\tpoints:", pointnum, '\n')    
    if (raddist==minz) data <- netsumNorm
    else data <- append(data,netsumNorm)
  }
  return(data)
}
# vx, vy, vz: vector starting point
#spc: sphere center
dist3D <- function (vx, vy, vz, spc){
  dist <- ((vx - spc[1])^2 + (vy - spc[2])^2 + (vz - spc[3])^2)^0.5
  return(dist)
}

#20hr data
filedir = 'C:/dropbox/My Dropbox/Mette/20_23h/'
#filedir = '/Users/miura/Dropbox/Mette/20_23h/'
filehead = '20_23hrfull_corrected_1_6_6_netdispZ'
#filehead = '20_23hrfullDriftCor_Track1_6_1_netdispZ'

#23hr data
#filedir = '/Users/miura/Dropbox/Mette/23h_/'
#filehead = '23hdatacut0_3dshifted_1_6_6_netdispZ'
#filehead = '23hdatacut0_3dshifted_1_6_1_netdispZ'
#27hr data
#filedir = '/Users/miura/Dropbox/Mette/27h/'
#filehead = 'data27_cut0_corrected_1_6_6_netdispZ'
#filehead = 'data27_cut0_corrected_1_6_1_netdispZ'

cat(paste(filedir, '\n',filehead), '\n')

# reference z position min and max
startz <- 0
endz <- 40

# zoning thickness
measurethickness = 10

# coordinate of the embryo center, calculated using an ImageJ script. 
spherecent = c(121, 113,70)

for (i in seq(startz,endz, by=5)){
  #netNorm <- upAndLowV2(i, measurethickness)
  netNorm <- radialZoning(i, measurethickness, spherecent)
  if (i == startz) {
    all <-netNorm
    unitlength <- length(netNorm)
  } else {
    all <- append(all, netNorm)
  }
}
#colorramp <- terrain.colors(24)
#colorramp <- cm.colors(36)
colorramp <- topo.colors(36)

minall <- min(all)
maxall <- max(all)
min3times <- -0.09
max3times <- 0.18
#ColorLevels <- seq(minall, maxall, length=length(colorramp))
ColorLevels <- seq(min3times, max3times, length=length(colorramp))

cat('min-all\t', minall, 'maxall\t', maxall, '\n')
allmatrix <- matrix(all, nrow=unitlength, ncol=length(all)/unitlength)

layout(matrix(data=c(1,2), nrow=1, ncol=2), widths=c(4,1), heights=c(1,1))
par(mar = c(3,5,2.5,2))
image(c(0:unitlength)*measurethickness, seq(startz,endz, by=5), allmatrix,
      zlim=c(min3times, max3times),
      col=colorramp,
      xlab="depth (micrometer)", 
      ylab="referece Zlevel")
title(main=filehead)

par(mar = c(3,2.5,2.5,2))
image(1, ColorLevels,
      matrix(data=ColorLevels, ncol=length(ColorLevels),nrow=1),
      col=colorramp,
      xlab="",ylab="",
      xaxt="n")
layout(1)


