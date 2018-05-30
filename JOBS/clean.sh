set -ex
 
seas="DJF JJA MAM SON"
dataset="OBS CESM ERAIN CESMDEBIAS"

################################################################################
# MAPS WITH CLIMATOLOGICAL MEAN
################################################################################
for data in $dataset; do
  cdo -splitseas -yseasmean -seassum -seldate,1979-01-01,2005-12-31 ../DATA/$data-RAIN-daily-CH.nc $data-
done

for data in $dataset; do
  for sea in $seas; do
    cdo outputtab,xind,yind,value $data-$sea.nc > temp
    gmt xyz2grd temp -I1 -R1/186/1/130 -G$data-$sea.grd
    GMT/plot_clima_CH.sh $data-$sea.grd ../CLIMATOLOGY/$data-$sea.ps $data $sea
    rm $data-$sea.grd temp
  done
done

rm -rf OBS-* ERAIN-* CESM-* DEBIAS-*



################################################################################
# ANNUAL CYCLE
################################################################################
for data in $dataset; do
  cdo -fldmean -ifthen ../DATA/MASK-OBS.nc -ymonmean -monsum -seldate,1979-01-01,2005-12-31 ../DATA/$data-RAIN-daily-CH.nc $data.nc
  cdo info $data.nc | grep -v Date | awk '{print $1, $9}' > $data.asc
  rm $data.nc
done

cat>coords.d<<EOF
1 a Jan
2 a Feb
3 a Mar
4 a Apr
5 a May
6 a Jun
7 a Jul
8 a Aug
9 a Sep
10 a Oct
11 a Nov
12 a Dec
EOF

REG="0/13/0/250"
FNAMEOUT="Annual-cycle.ps"
gmt psxy -R$REG -JX14c/8c -T -K > $FNAMEOUT
gmt psbasemap -R -J -BneWS+t"" -Bxccoords.d -By+l"Prec. (mm)" -Byafg -O -K --MAP_GRID_PEN_PRIMARY=faint,grey50 >> $FNAMEOUT
gmt psxy -R -J OBS.asc    -O -K -Sb0.2b1 -Gblack -io-0.3,1>> $FNAMEOUT
gmt psxy -R -J ERAIN.asc -O -K -Sb0.2b1 -Groyalblue1 -io-0.1,1 >> $FNAMEOUT
gmt psxy -R -J CESM.asc   -O -K -Sb0.2b1 -Gred3 -io0.1,1 >> $FNAMEOUT
gmt psxy -R -J DEBIAS.asc -O -K -Sb0.2b1 -Gseagreen -i0o0.3,1 >> $FNAMEOUT

gmt pslegend -R -J -F+p1p+r0p+gsnow -DjTR+w6c+o1.6c/0.1c  -K -O <<EFG >> $FNAMEOUT
N 1
S 0.2c - .4c - 0.2c,black 0.6c OBS
S 0.2c - .4c - 0.2c,royalblue1 0.6c WRF-ERA
S 0.2c - .4c - 0.2c,red3 0.6c WRF-CESM
S 0.2c - .4c - 0.2c,seagreen 0.6c WRF-CESM corrected
EFG

gmt psxy -R -J -T -O >> $FNAMEOUT
gmt psconvert -Tf -A $FNAMEOUT
rm $FNAMEOUT coords.d OBS.asc ERAIN.asc CESM.asc DEBIAS.asc



################################################################################
# CORRELATIONS BY REGIONS 
################################################################################

date="1979-01-01,2005-12-31"

cdo -splitseas -seldate,$date ../DATA/ERAIN-RAIN-daily-CH.nc ERAIN-
cdo -splitseas -seldate,$date ../DATA/OBS-RAIN-daily-CH.nc OBS-
cdo -splitseas -seldate,$date ../DATA/CESMA-RAIN-daily-CH.nc CESM-

FNAMEOUT="../REGIONALIZATION/COR.ps"
gmt makecpt -Cjet -T0/1/0.1 -I > pepe.cpt
gmt psxy -JX2c -Xf2c -Yf24c -R0/1/0/1 -T -K > $FNAMEOUT

for sea in DJF MAM JJA SON; do
  gmt psxy -J -R -T -Y-5c -Xf3c -K -O >> $FNAMEOUT
  for data in OBS ERAIN CESM; do
    file=$(find ../REGIONALIZATION/SUMMARY-$data -name "Reg*$sea*HR.nc"  )
    nregions=$(basename $file | cut -c 13-13 )
    echo $data $sea $nregions

    for i in $(seq 1 $nregions); do
      cdo -eqc,$i $file mask.nc
      cdo mul ../DATA/OBS/MASK-OBS.nc mask.nc mask2.nc
      cdo -fldmean -ifthen mask2.nc $data-$sea.nc $data-$i.nc
    done

    rm -rf COR-$data-$sea.dat
    for i in $(seq 1 $nregions); do
      for j in $(seq 1 $nregions); do
        cor=$(cdo output -timcor $data-$i.nc $data-$j.nc) 
        echo $i $j $cor >> COR-$data-$sea.dat
      done
    done

    gmt xyz2grd -GCOR-$data-$sea.grd -R1/$nregions/1/$nregions -I1 COR-$data-$sea.dat
    gmt psbasemap -JX4c -R0.5/$nregions.5/0.5/$nregions.5 -BSWne+t"" -Bx1a -By1a -K -O >> $FNAMEOUT
    gmt grdimage -R -J COR-$data-$sea.grd -Cpepe.cpt -O -K >> $FNAMEOUT
    gmt psxy -J -R -T -X5c -K -O >> $FNAMEOUT

  done
done

gmt psxy -Xf1c -Yf1c -JX17c/25c -R0/17/0/25 -T -K -O >> $FNAMEOUT
echo 4  23 OBS | gmt pstext -J -R -K -O -F+f22 >> $FNAMEOUT
echo 9  23 WRF-ERAIN | gmt pstext -J -R -K -O -F+f22 >> $FNAMEOUT
echo 14 23 WRF-CESM | gmt pstext -J -R -K -O -F+f22  >> $FNAMEOUT

echo 1 20 DJF | gmt pstext -J -R -K -O -F+f22+a90 >> $FNAMEOUT
echo 1 15 MAM | gmt pstext -J -R -K -O -F+f22+a90 >> $FNAMEOUT
echo 1 10 JJA | gmt pstext -J -R -K -O -F+f22+a90 >> $FNAMEOUT
echo 1 5 SON | gmt pstext -J -R -K -O -F+f22+a90 >> $FNAMEOUT

gmt psscale -Cpepe.cpt -DjBC+w12c/.5c+h -R -J -K -O -L0.2 -B+l"cor">> $FNAMEOUT

gmt psxy -J -R -T -O >> $FNAMEOUT
gmt psconvert -Tf -A $FNAMEOUT
rm $FNAMEOUT







################################################################################
# TAYLOR DIAGRAM
################################################################################

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



################################################################################
#BIASED-DEBIASED CORRELATION MAPS
################################################################################

seas="DJF JJA MAM SON"
for sea in $seas; do
  cdo timcor -selseas,$sea ../DATA/CESM-RAIN-daily-CH.nc -selseas,$sea ../CESMDEBIAS-RAIN-daily-CH.nc cor-$sea.nc
  cdo outputtab,xind,yind,value cor-$sea.nc > kk
  gmt xyz2grd kk -I1 -R1/186/1/130 -Gcor-$sea.grd
  rm kk cor-$sea.nc
done

GMT/plot_correlations_CH.sh

mv cor.pdf ../CLIMATOLOGY/COR-BIAS-DEBIAS.pdf
