################################################################################
# TAYLOR DIAGRAM
################################################################################

seas="DJF JJA MAM SON"
dataset="OBS CESM ERAIN CESMDEBIAS"
date="1979-01-01,2005-12-31"

cdo -splitseas -seldate,$date ../DATA/ERAIN-RAIN-daily-CH.nc ERAIN-
cdo -splitseas -seldate,$date ../DATA/OBS-RAIN-daily-CH.nc OBS-
cdo -splitseas -seldate,$date ../DATA/CESM-RAIN-daily-CH.nc CESM-

rm -rf cor.dat
for sea in DJF MAM JJA SON; do
  file=$(find ../REGIONALIZATION/SUMMARY-ERAIN -name "Reg*$sea*HR.nc"  )
  nregions=$(basename $file | cut -c 13-13 )

  for i in $(seq 1 $nregions); do
    cdo -eqc,$i $file mask.nc
    cdo mul ../DATA/OBS/MASK-OBS.nc mask.nc mask2.nc
    cdo -fldmean -ifthen mask2.nc ERAIN-$sea.nc ERAIN-$i-$sea.nc
    cdo -fldmean -ifthen mask2.nc OBS-$sea.nc OBS-$i-$sea.nc
    cdo outputf,%g,1 ERAIN-$i-$sea.nc > ERAIN-$i-$sea.dat
    cdo outputf,%g,1 OBS-$i-$sea.nc > OBS-$i-$sea.dat
    rm mask.nc mask2.nc
    cor=$(cdo outputf,%g,1 -timcor ERAIN-$i-$sea.nc OBS-$i-$sea.nc)
    echo $sea $i $cor >> cor.dat
  done

  cdo outputf,%g,1 -fldmean -ifthen ../DATA/OBS/MASK-OBS.nc ERA-$sea.nc > ERA-$sea.dat

  paste ERAIN-?-$sea.dat > ERAIN-$sea.dat
  paste OBS-?-$sea.dat > OBS-$sea.dat
done

for sea in DJF MAM JJA SON; do
  awk "\$1 ~ \"$sea\" {suma+=\$3; n+=1}; END{print \"$sea\", suma/n }" cor.dat
done
awk "{suma+=\$3; n+=1}; END{print suma/n }" cor.dat


cat>in2R<<EOF
library(plotrix)
pdf("../REGIONALIZATION/Taylor.pdf")
pdf("Taylor.pdf")

ref<-read.table("OBS-DJF.dat")
model<-read.table("ERAIN-DJF.dat")
taylor.diagram(ref[,1], model[,1], pch=0, normalize=TRUE, pcex=1.5, col="blue", add=FALSE, main="", ngamma=6 )
taylor.diagram(ref[,2], model[,2], pch=0, normalize=TRUE, pcex=1.5, col="red", add=TRUE)
taylor.diagram(ref[,3], model[,3], pch=0, normalize=TRUE, pcex=1.5, col="cyan", add=TRUE)
taylor.diagram(ref[,4], model[,4], pch=0, normalize=TRUE, pcex=1.5, col="magenta", add=TRUE)
taylor.diagram(ref[,5], model[,5], pch=0, normalize=TRUE, pcex=1.5, col="#ffdd66", add=TRUE)

ref<-read.table("OBS-MAM.dat")
model<-read.table("ERAIN-MAM.dat")
taylor.diagram(ref[,1], model[,1], pch=1, normalize=TRUE, pcex=1.5, col="blue", add=TRUE)
taylor.diagram(ref[,2], model[,2], pch=1, normalize=TRUE, pcex=1.5, col="red", add=TRUE)
taylor.diagram(ref[,3], model[,3], pch=1, normalize=TRUE, pcex=1.5, col="cyan", add=TRUE)
taylor.diagram(ref[,4], model[,4], pch=1, normalize=TRUE, pcex=1.5, col="magenta", add=TRUE)
taylor.diagram(ref[,5], model[,5], pch=1, normalize=TRUE, pcex=1.5, col="#ffdd66", add=TRUE)


ref<-read.table("OBS-JJA.dat")
model<-read.table("ERAIN-JJA.dat")
taylor.diagram(ref[,1], model[,1], pch=2, normalize=TRUE, pcex=1.5, col="blue", add=TRUE)
taylor.diagram(ref[,2], model[,2], pch=2, normalize=TRUE, pcex=1.5, col="red", add=TRUE)
taylor.diagram(ref[,3], model[,3], pch=2, normalize=TRUE, pcex=1.5, col="cyan", add=TRUE)
taylor.diagram(ref[,4], model[,4], pch=2, normalize=TRUE, pcex=1.5, col="magenta", add=TRUE)
taylor.diagram(ref[,5], model[,5], pch=2, normalize=TRUE, pcex=1.5, col="#ffdd66", add=TRUE)


ref<-read.table("OBS-SON.dat")
model<-read.table("ERAIN-SON.dat")
taylor.diagram(ref[,1], model[,1], pch=5, normalize=TRUE, pcex=1.5, col="blue", add=TRUE)
taylor.diagram(ref[,2], model[,2], pch=5, normalize=TRUE, pcex=1.5, col="red", add=TRUE)
taylor.diagram(ref[,3], model[,3], pch=5, normalize=TRUE, pcex=1.5, col="cyan", add=TRUE)
taylor.diagram(ref[,4], model[,4], pch=5, normalize=TRUE, pcex=1.5, col="magenta", add=TRUE)
taylor.diagram(ref[,5], model[,5], pch=5, normalize=TRUE, pcex=1.5, col="#ffdd66", add=TRUE)
taylor.diagram(ref[,6], model[,6], pch=5, normalize=TRUE, pcex=1.5, col="#00dd66", add=TRUE)
EOF

R CMD BATCH in2R

