################################################################################
# QUANTILE MAPPING
################################################################################

days=1
for mon  in $(seq -w 1 12); do
  case $mon in
    01) sea=DJF ; nreg=6;;
    02) sea=DJF ; nreg=6;;
    03) sea=MAM ; nreg=6;;
    04) sea=MAM ; nreg=6;;
    05) sea=MAM ; nreg=6;;
    06) sea=JJA ; nreg=5;;
    07) sea=JJA ; nreg=5;;
    08) sea=JJA ; nreg=5;;
    09) sea=SON ; nreg=4;;
    10) sea=SON ; nreg=4;;
    11) sea=SON ; nreg=4;;
    12) sea=DJF ; nreg=6;;
  esac

  cdo -f ext -runsum,$days -ifthen ../DATA/MASK-OBS.nc -selmon,$mon -seldate,1979-01-01,2005-12-31 ../DATA/CESM-RAIN-daily-CH.nc prec-CESM-$mon.ext
  cdo -f ext -runsum,$days -ifthen ../DATA/MASK-OBS.nc -selmon,$mon -seldate,1979-01-01,2005-12-31 ../DATA/OBS-RAIN-daily-CH.nc prec-OBS-$mon.ext
  cdo setctomiss,-999.99 prec-OBS-$mon.ext kk.ext
  mv kk.ext prec-OBS-$mon.ext

  regions=$(cdo info ../REGIONALIZATION/SUMMARY-CESMDENICA/Regions-$sea-?groups-HR.nc | grep -v Date  | awk '{print $11}')
  cdo -ifthen ../DATA/MASK-OBS.nc ../REGIONALIZATION/SUMMARY-CESMDENICA/Regions-$sea-?groups-HR.nc mask-$mon.nc
  cdo -f ext copy mask-$mon.nc mask-$mon.ext

  ../PROGRAMS/qq-pointwise.x prec-CESM-$mon.ext prec-OBS-$mon.ext mask-$mon.ext
  cdo -f nc -g ../DATA/MASK-OBS.nc setctomiss,-9999 fort.20 QQCESM-runmean$days-$mon.nc

  cdo smooth,radius=4km,nsmooth=3 QQCESM-runmean$days-$mon.nc kk.nc
  cdo -f ext copy kk.nc kk.ext
  ../PROGRAMS/sort-extra.x kk.ext kk2.ext

  mv kk2.ext QQCESM-runmean$days-$mon.ext 

  rm -f kk.nc kk2.ext

  cdo -f ext ifthen ../DATA/MASK-OBS.nc QQCESM-runmean1-$mon.ext qq.ext
  ../PROGRAMS/qmapping-pointwise.x qq.ext prec-CESM-$mon.ext qmap-$mon.ext
done

rm -rf ../CESMDEBIASED-RAIN-daily-CH.nc
cdo -f nc -g ../DATA/MASK-OBS.nc mergetime qmap-??.ext ../DATA/CESM-RAIN-daily-CH-DEBIASED.nc
