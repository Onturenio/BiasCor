################################################################################
#PDF
################################################################################

seas="DJF JJA MAM SON"
dataset="OBS CESM ERAIN CESMDEBIAS"

for data in $dataset; do
  cdo -fldmean -ifthen ../DATA/MASK-OBS.nc -seldate,1979-01-01,2005-12-31 ../DATA/$data-RAIN-daily-CH.nc prec-$data.nc
done

for sea in $seas; do
  for data in $dataset; do
    cdo -f ext -selseas,$sea prec-$data.nc prec-$data-$sea.ext

    cdo info prec-$data-$sea.ext | grep -v Date | awk '{print $9}' > prec-$data-$sea.asc
    cp prec-$data-$sea.asc fort.10
    N=$(wc -l < fort.10)
    min=$(sort -g fort.10    | head -1)
    max=$(sort -g -r fort.10 | head -1)
    bw=$(echo $max $min | awk '{print ($1-$2)/20}')

    ../PROGRAMS/kernel-density-estimation.x>PDF-seasonal-$data-$sea.dat<<EOF
$N
0
$max
$bw
EOF
    rm -rf fort.10
  done
done


FNAMEOUT="../PDF.ps"

gmt psxy -R1/2/1/2 -JX6cl/3c -T -K -Y20 > $FNAMEOUT

sea=DJF
REG=$(gmt_get_region PDF-seasonal-ERAIN-$sea.dat PDF-seasonal-OBS-$sea.dat PDF-seasonal-CESM-$sea.dat PDF-seasonal-CESMDEBIAS-$sea.dat | awk 'BEGIN{FS="/"; OFS="/"} {$1=1; print $0}')
gmt psxy -R$REG -J PDF-seasonal-ERAIN-$sea.dat -Wthicker,royalblue1 -O -K >> $FNAMEOUT
gmt psxy -R -J PDF-seasonal-OBS-$sea.dat -Wthicker,black -O -K >> $FNAMEOUT
gmt psxy -R -J PDF-seasonal-CESM-$sea.dat -Wthicker,red3 -O -K >> $FNAMEOUT
gmt psxy -R -J PDF-seasonal-CESMDEBIAS-$sea.dat -Wthicker,seagreen -O -K >> $FNAMEOUT
gmt psbasemap -R -J -BneWS -Bxa2g2 -Bya0.03fg0.03+l"PDF" -O -K --MAP_GRID_PEN_PRIMARY=faint,black,- >> $FNAMEOUT
echo $sea |  gmt pstext -R -J -O -K -F+cTR -D-0.2c/-0.2c -Gwhite >> $FNAMEOUT 

gmt psxy -R -J -X7 -T -K -O >> $FNAMEOUT

sea=MAM
REG=$(gmt_get_region PDF-seasonal-ERAIN-$sea.dat PDF-seasonal-OBS-$sea.dat PDF-seasonal-CESM-$sea.dat PDF-seasonal-CESMDEBIAS-$sea.dat | awk 'BEGIN{FS="/"; OFS="/"} {$1=1; print $0}')
gmt psxy -R$REG -J PDF-seasonal-ERAIN-$sea.dat -Wthicker,royalblue1 -O -K >> $FNAMEOUT
gmt psxy -R -J PDF-seasonal-OBS-$sea.dat -Wthicker,black -O -K >> $FNAMEOUT
gmt psxy -R -J PDF-seasonal-CESM-$sea.dat -Wthicker,red3 -O -K >> $FNAMEOUT
gmt psxy -R -J PDF-seasonal-CESMDEBIAS-$sea.dat -Wthicker,seagreen -O -K >> $FNAMEOUT
gmt psbasemap -R -J -BnEwS -Bxa2g2 -Bya0.03fg0.03+l"PDF" -O -K --MAP_GRID_PEN_PRIMARY=faint,black,- >> $FNAMEOUT
echo $sea |  gmt pstext -R -J -O -K -F+cTR -D-0.2c/-0.2c -Gwhite >> $FNAMEOUT 

gmt psxy -R -J -Y-4 -X-7 -T -K -O >> $FNAMEOUT

sea=JJA
REG=$(gmt_get_region PDF-seasonal-ERAIN-$sea.dat PDF-seasonal-OBS-$sea.dat PDF-seasonal-CESM-$sea.dat PDF-seasonal-CESMDEBIAS-$sea.dat | awk 'BEGIN{FS="/"; OFS="/"} {$1=1; print $0}')
gmt psxy -R$REG -J PDF-seasonal-ERAIN-$sea.dat -Wthicker,royalblue1 -O -K >> $FNAMEOUT
gmt psxy -R -J PDF-seasonal-OBS-$sea.dat -Wthicker,black -O -K >> $FNAMEOUT
gmt psxy -R -J PDF-seasonal-CESM-$sea.dat -Wthicker,red3 -O -K >> $FNAMEOUT
gmt psxy -R -J PDF-seasonal-CESMDEBIAS-$sea.dat -Wthicker,seagreen -O -K >> $FNAMEOUT
gmt psbasemap -R -J -BneWS -Bxa2g2+l"prec (mm)" -Bya0.03fg0.03+l"PDF" -O -K --MAP_GRID_PEN_PRIMARY=faint,black,- >> $FNAMEOUT
echo $sea |  gmt pstext -R -J -O -K -F+cTR -D-0.2c/-0.2c -Gwhite >> $FNAMEOUT 

gmt psxy -R -J  -X7 -T -K -O >> $FNAMEOUT

sea=SON
REG=$(gmt_get_region PDF-seasonal-ERAIN-$sea.dat PDF-seasonal-OBS-$sea.dat PDF-seasonal-CESM-$sea.dat PDF-seasonal-CESMDEBIAS-$sea.dat | awk 'BEGIN{FS="/"; OFS="/"} {$1=1; print $0}')
gmt psxy -R$REG -J PDF-seasonal-ERAIN-$sea.dat -Wthicker,royalblue1 -O -K >> $FNAMEOUT
gmt psxy -R -J PDF-seasonal-OBS-$sea.dat -Wthicker,black -O -K >> $FNAMEOUT
gmt psxy -R -J PDF-seasonal-CESM-$sea.dat -Wthicker,red3 -O -K >> $FNAMEOUT
gmt psxy -R -J PDF-seasonal-CESMDEBIAS-$sea.dat -Wthicker,seagreen -O -K >> $FNAMEOUT
gmt psbasemap -R -J -BnEwS -Bxa2g2+l"prec (mm)" -Bya0.03fg0.03+l"PDF" -O -K --MAP_GRID_PEN_PRIMARY=faint,black,- >> $FNAMEOUT
echo $sea |  gmt pstext -R -J -O -K -F+cTR -D-0.2c/-0.2c -Gwhite >> $FNAMEOUT 

gmt pslegend -R -JX13c -F+p1p+r0p -DjBC+w8c -X-7 -Y-3 -K -O <<EFG >> $FNAMEOUT
N 2
S 0.3c - .5c - thicker,black 0.8c OBS
S 0.3c - .5c - thicker,red3 0.8c WRF-CESM
S 0.3c - .5c - thicker,royalblue1 0.8c WRF-ERAIN
S 0.3c - .5c - thicker,seagreen 0.8c Corrected
EFG

gmt psxy -R -J -T -O >> $FNAMEOUT
gmt psconvert -Tf -A $FNAMEOUT
rm $FNAMEOUT
