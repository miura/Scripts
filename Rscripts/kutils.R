# Kota Miura
# misc utilities


xtrailZeros <- function(avec){
  # removes traling zeros from a vector
  return (avec[rev(cumsum(rev(avec))) > 0])
}