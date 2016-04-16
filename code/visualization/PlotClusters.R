# This script plots example Clusters of Rainfall


plotEOF=function(year,month){
  # year is integer between 1901 and 2009
  # month is either an integer between 1 and 12 or capitalized proper name
  
  setwd('C:/Users/Daniel/Desktop/Data Mining Project/pre-visualization')
  AllClust=read.csv("cluster_unpickle.csv",header=F)  # dim 
  locations=unlist(read.csv("rainfall_coordinates.csv",header=F))
  locations=matrix(locations,ncol=2,byrow=F)
  
  # Select month
  mon=(year-1901)*12-(12-month)
  Clust<-unlist(AllClust[mon,])
  
  # Turn into matrix
  Clustmat=matrix(Clust,nrow=44,ncol=72,byrow=T)
  Clustmat[Clustmat==-1]=NA
  
  plotx=unique(locations[,1])
  ploty=(unique(locations[,2])+35.5)/2
  
  if (month==1){month="January"}
  if (month==2){month="February"}
  if (month==3){month="March"}
  if (month==4){month="April"}
  if (month==5){month="May"}
  if (month==6){month="June"}
  if (month==7){month="July"}
  if (month==8){month="August"}
  if (month==9){month="September"}
  if (month==10){month="October"}
  if (month==11){month="November"}
  if (month==12){month="December"}
  
  n=length(unique(as.numeric(Clustmat))-1)
  image(plotx,ploty,t(Clustmat),xlab="Longitude",ylab="Latitude",main=paste("Clustering Scheme for",year),col=rainbow(n))
  world(add=T)
  
}

year=1999
month=6
library(maps)

# animation
for (j in 1901:2009){
  for (i in 1:12){
    plotEOF(j,i)
    Sys.sleep(0.001)
  }
}
  
# Display
  plotEOF(1971,6)
}