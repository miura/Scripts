#mayumi plots for profiles, 3x3
multiplot <- function(startnum){
  opar <- par()
  par(mfrow=c(3,3))
  for (i in c(startnum:(startnum+9-1))){
    print(i)
    chead <- paste("Profile", formatC(i, width=2, flag="0"), "_int", sep="")
    print(chead)    
    plot(xtrailZeros(prof3d[,chead]), main=chead, ylab = "mean int")
  }
  par(opar)
}
