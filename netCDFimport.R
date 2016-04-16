#######  This script imports NetCDF files and saves them as a series of 2D xy slices! ##########

importSST=function(name,lat.cutoff){
  library(ncdf4)
  nc <- nc_open(name)      # Load from netCDF format
  
  z<-ncvar_get(nc,'anom')      # Extract information
  lat<-ncvar_get(nc,'Y')
  lon<-ncvar_get(nc,'X')
  
  image(lon,lat,z[,,1])        # Plot GLOBAL to make sure it's coming out okay
  
  nrows=length(lon)
  ncols=length(lat)
  ntime = length(z[1,1,])      # Monthly since 01-01-1853
  nyrs = round(ntime/12)
  N = nrows*ncols
  
  ### Lat - Long grid..
  ygrid=seq(min(lat),max(lat),by=2)
  ny=length(ygrid)
  
  xgrid=seq(min(lon),max(lon),by=2)
  #xgrid[xgrid > 180]=xgrid[xgrid > 180]-360	#longitude on 0-360 grid if needed
  xgrid[xgrid > 180]=xgrid[xgrid > 180]
  nx=length(xgrid)
  
  xygrid=matrix(0,nrow=nx*ny,ncol=2)
  
  i=0
  for(iy in 1:ny){
    for(ix in 1:nx){
      i=i+1
      xygrid[i,1]=ygrid[iy]
      xygrid[i,2]=xgrid[ix]
    }
  }
  
  index=1:(length(lat)*length(lon))
  index1=index[is.na(z[,,1])==F]
  
  ## Index of locations corresponding to Global Tropics
  ### grids with non-missing data and between 25N-25S
  xlongs = xygrid[,2]
  ylats = xygrid[,1]
  indextrop = index[ylats >= -lat.cutoff & ylats <= lat.cutoff & xlongs >= 125 & xlongs <= 300]
  
  EP<-z[,,1][indextrop]
  plotx=unique(xlongs[xlongs >= 125 & xlongs <= 300])
  ploty=unique(ylats[ylats >= -lat.cutoff & ylats <= lat.cutoff])
  zz=matrix(EP,ncol=length(ploty),byrow=F)
  
  image(plotx,ploty,zz)    # Check Local Area to make sure it looks okay
  
  # Now we need to take the data from the z data for all slices of z
  ystrt=which(unique(ylats)==min(ploty))
  yend=which(unique(ylats)==max(ploty))
  xstrt=which(unique(xlongs)==min(plotx))
  xend=which(unique(xlongs)==max(plotx))
  
  return(z[xstrt:xend,ystrt:yend,])
}
 
importRectangle=function(name,longs,lats){
  
  # This imports an aribrary rectangle, takes 3 args: 
  # name is filename in directory 
  # lat & long are a 2-object vector with min then max --> c(min,max)
  
  library(ncdf4)
  nc <- nc_open(name)      # Load from netCDF format
  
  z<-ncvar_get(nc,'anom')      # Extract information
  lat<-ncvar_get(nc,'Y')
  lon<-ncvar_get(nc,'X')
  
  image(lon,lat,z[,,1])        # Plot to make sure it's coming out okay
  
  nrows=length(lon)
  ncols=length(lat)
  ntime = length(z[1,1,])      # Monthly since 01-01-1853
  nyrs = round(ntime/12)
  N = nrows*ncols
  
  ### Lat - Long grid..
  ygrid=seq(min(lat),max(lat),by=2)
  ny=length(ygrid)
  
  xgrid=seq(min(lon),max(lon),by=2)
  #xgrid[xgrid > 180]=xgrid[xgrid > 180]-360	#longitude on 0-360 grid if needed
  xgrid[xgrid > 180]=xgrid[xgrid > 180]
  nx=length(xgrid)
  
  xygrid=matrix(0,nrow=nx*ny,ncol=2)
  
  i=0
  for(iy in 1:ny){
    for(ix in 1:nx){
      i=i+1
      xygrid[i,1]=ygrid[iy]
      xygrid[i,2]=xgrid[ix]
    }
  }
  
  index=1:(length(lat)*length(lon))
  index1=index[is.na(z[,,1])==F]
  
  ## Index of locations corresponding to Global Tropics
  ### grids with non-missing data and between 25N-25S
  xlongs = xygrid[,2]
  ylats = xygrid[,1]
  indextrop = index[ylats >= lats[1] & ylats <= lats[2] & xlongs >= longs[1] & xlongs <= longs[2]]
  
  EP<-z[,,1][indextrop]
  plotx=unique(xlongs[xlongs >= longs[1] & xlongs <= longs[2]])
  ploty=unique(ylats[ylats >= lats[1] & ylats <= lats[2]])
  zz=matrix(EP,ncol=length(ploty),byrow=F)
  
  image(plotx,ploty,zz)    # Check to make sure it looks okay
  
  # Now we need to take the data from the z data for all slices of z
  ystrt=which(unique(ylats)==min(ploty))
  yend=which(unique(ylats)==max(ploty))
  xstrt=which(unique(xlongs)==min(plotx))
  xend=which(unique(xlongs)==max(plotx))
  
  return(z[xstrt:xend,ystrt:yend,])
}

################## MAIN ##########################

lat.cutoff=20   # set this value for tropics cutoff
name="SST.nc"   # set the name of the netCDF file

setwd('C:/Users/Daniel/Desktop/Data Mining Project')   # location of the NetCDF file
library(RNetCDF)

twenty=importSST(name,20)
write.csv(twenty,file=gzfile("EP20.csv.gz"))

fifteen=importSST(name,15)
write.csv(fifteen,file=gzfile("EP15.csv.gz"))

ten=importSST(name,10)
write.csv(ten,file=gzfile("EP10.csv.gz"))

IO=importRectangle(name,longs=c(50,110),lats=c(-45,25))
write.csv(IO,file=gzfile("IO.csv.gz"))