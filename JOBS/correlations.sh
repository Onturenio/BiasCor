################################################################################
# CORRELATIONS BY REGIONS 
################################################################################

seas="DJF JJA MAM SON"
dataset="OBS CESM ERAIN CESMDEBIAS"
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
