################################################################################
# MAPS WITH CLIMATOLOGICAL MEAN
################################################################################

seas="DJF JJA MAM SON"
dataset="OBS CESM ERAIN CESMDEBIAS"

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
