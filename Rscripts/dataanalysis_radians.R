# analysis of particle tracker output. 
# for a single trajectory, get theta for each time points

ptdata <- read.csv("Z:/11EMBOcourse/trials/PTresults.csv")
t1x <- ptdata[ptdata$Trajectory==2, 4]
t1y <- ptdata[ptdata$Trajectory==2, 5]
d1x <- t1x[2:length(t1x)] - t1x[1:length(t1x)-1]
d1y <- t1y[2:length(t1y)] - t1y[1:length(t1y)-1]
tpol1 <- toPolar(dx, dy)
tpol1

#check
tpol1["t11"]

# to get all data, for loop could be used but alternative method (see bootom):
dtx <- diff(ptdata$x)
dty <- diff(ptdata$y)
dtraj <- diff(ptdata$Trajectory)
dtxc <- dtx[dtraj == 0]
dtyc <- dty[dtraj == 0]
pol = toPolar(dtxc, dtyc)
angledata <- pol[1:(length(pol)/2)]
outdata <- data.frame(angledata)

#plotting general histogram
bins <- seq(-pi, pi, pi/50)
hh <- hist(angledata, breaks=bins)

#plotting radial plots
library(plotrix)
# prepare index
hhcounts <- hh$counts
radpos <- hh$breaks[1:length(hh$breaks)-1] + diff(hh$breaks)
labpos = seq(-pi, 3/4*pi, by=pi/4)
radlabels <- as.character(format(labpos, digits=2))
radial.plot(hh$counts,radpos,
            rp.type="p",
            main="EB1 directionality",
            line.col="blue", 
            labels=radlabels, 
            label.pos=labpos, 
            radial.lim=c(0, 60),
            mar=c(2, 2, 6, 2))
text(-100, 80, paste("myu: ",as.character(vm.ml(angledata)$mu)))
text(-100, 70, paste("kappa: ",as.character(vm.ml(angledata)$kappa)))

# rationale behind the way by shorter example
# aa <-c(1:10, 101:110)
# daa <-diff(aa)
# bb <- c(rep(c(1), 10), rep(c(2), 10))
# dbb <- diff(bb)
# daac <- daa[dbb == 0]
