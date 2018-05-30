################################################################################
#BIASED-DEBIASED CORRELATION MAPS
################################################################################
 
seas="DJF JJA MAM SON"
dataset="OBS CESM ERAIN CESMDEBIAS"

seas="DJF JJA MAM SON"
for sea in $seas; do
  cdo timcor -selseas,$sea ../DATA/CESM-RAIN-daily-CH.nc -selseas,$sea ../CESMDEBIAS-RAIN-daily-CH.nc cor-$sea.nc
  cdo outputtab,xind,yind,value cor-$sea.nc > kk
  gmt xyz2grd kk -I1 -R1/186/1/130 -Gcor-$sea.grd
  rm kk cor-$sea.nc
done

GMT/plot_correlations_CH.sh

mv cor.pdf ../CLIMATOLOGY/COR-BIAS-DEBIAS.pdf
