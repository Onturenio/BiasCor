################################################################################
# ANNUAL CYCLE
################################################################################
 
seas="DJF JJA MAM SON"
dataset="OBS CESM ERAIN CESMDEBIAS"

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
