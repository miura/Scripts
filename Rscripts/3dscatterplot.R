# for converting xyz data to show OpenGL plot. 
# Kota Miura (miura@embl.de)
# uses package rgl

library(rgl)
#coords <- read.table("Pairs_NowCorrectmod.txt")

color <- rep("blue", length(x1))
colorV <- c(color, rep("red", length(x2)))
x <- coords[[1]]
y <- coords[[2]]
z <- coords[[3]]
x <- c(x, coords[[4]])
y <- c(y, coords[[5]])
z <- c(z, coords[[6]])
#plot3d(x, y, z, col=colorV)
# for(i in 1:360) rgl.viewpoint(i,i/4) # rotate view