# This code imports the rectangualr India precip data in Excel format
# then cuts out the points which are not in actual India

setwd("C:/Users/Daniel/Desktop/Data Mining Project")
raw=unlist(read.csv("IndiaPrecip.csv",header=T))
data=matrix(raw, ncol=4,byrow=F)
rm(raw)

longpts=unique(read.csv("IndiaPrecip_coordinates.csv",header=F)$V1)
latpts=unique(read.csv("IndiaPrecip_coordinates.csv",header=F)$V2)
coords=read.csv("IndiaPrecip_coordinates.csv",header=F)

# Get rid of the stupid N in long coordinates
str=attr(formatC(latpts, digits=3, width=7, format="f", flag=0 ),"levels")
latpts=sort(as.numeric(substr(str,1,nchar(str)-1)))

# # Extract the Lats
# coords=matrix(raw,ncol=2,byrow=F)
# longpts=unique(coords[,1])

# We need to first figure out the dataset dimensions
single.month=data[data[,3]==data[2000,3],]

averaged.months=apply(data,c(1,2,4),mean)
n=length(data)/length(single.month)  # number of months

# Visualize
z=matrix(single.month[,4],ncol=length(longpts),byrow=T)
image(longpts,latpts,t(z))
library(maps)
library(mapdata)
world(add=T)

################################ Perform mask
# Convert grid to raster
library(sp)
library(spatstat)
library(rgdal)
library(raster)
xy=as.data.frame(coords)
names(xy)=c("x","y")

# UGH...need to get rid of the pesky N in long coordinates
str=as.character(xy$y)
xy$y=as.numeric(substr(str,1,nchar(str)-1))

r <- rasterFromXYZ(cbind(xy,single.month[,4]))
india=getData(name = "GADM", country = "India", level = 1) 
r <- mask(r,india)

############################ apply the masked data to the actual dataset..
#select NAs from raster
index=is.na(values(r))
#Problem is..raster structure is different from data structure, so we have to do it by reversed rows
# make a toy matrix for transpose
aa=matrix(index,ncol=length(longpts),nrow=length(latpts),byrow=T)
# perform the horizontal flip
index=t(apply(aa,2,rev))

slice=single.month[,4]
#slice[index]=NA
z=matrix(slice,ncol=length(longpts),byrow=T)
z=t(z)
z[index]=NA
#50 by 14-16 (some island) need to also be nulled
z[50,14:16]=NA
image(longpts,latpts,z)
map("worldHires", regions="India", exact=TRUE,add=T, plot=TRUE)

############################ apply to one slice then to full dataset
z=as.data.frame(z)
colnames(z)<-latpts
rownames(z)<-longpts

# We select which to get the coordinates of
#keep=!is.na(z)
select=which(!is.na(z),arr.ind=T)
# get the coordinates of selected
y=rownames(z)[select[,1]]
x=colnames(z)[select[,2]]
out=matrix(as.numeric(cbind(x,y)),ncol=2,byrow=F)  # convert to numeric, so it's long

# now select the rows from 'data' with matching rows
# This is really tricky because the given data isn't well processed. Much easier to work in multi-dim arrays

  # Step 1, get lat/lon combos from selected and general
  coordlat = read.csv("IndiaPrecip_coordinates.csv",header=F)$V2
           # Get rid of the stupid N in long coordinates
  str=attr(formatC(coordlat, digits=3, width=7, format="f", flag=0 ),"levels")
  coordlat=sort(as.numeric(substr(str,1,nchar(str)-1)))
  latlong.ID=paste(coordlat,read.csv("IndiaPrecip_coordinates.csv",header=F)$V1)
  out.ID=paste(out[,1],out[,2])
  
  # Step 2, make the first month with the correct lat/lon formats
  single.month[,2]=coordlat
  single.Ind=paste(single.month[,2],single.month[,1])
  
  # Step 3, match the concurrent rows
  data[,2]=single.month[,2]
  cutdata=data[single.Ind %in% out.ID,]  # DONE
  
write.csv(cutdata, file = "CutIndiaPrecip.csv")
