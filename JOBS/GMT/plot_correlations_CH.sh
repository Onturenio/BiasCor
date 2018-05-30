################################################################################
#GMT TO PLOT CORRELATION MAPS
################################################################################


FNAMEOUT=COR.ps

varname=`ncdump -h corç | grep float| grep time | awk '{print $2}' | awk -F\( '{print $1}'`

# This defines the proyection and the size of the map
RFLAG="-R5.821136/45.66386/10.66321/48.00829r"
RJFLAG="${RFLAG} -JL8.781/47.16/47.16/47.16/10c"

# Some other common features
NOLAKES="-A100/0/1"
OK="-O -K"

gmt set COLOR_NAN gray
width=$(gmt mapproject $RJFLAG -Ww)
height=$(gmt mapproject $RJFLAG -Wh)

gmt makecpt -Cjet -T0.8/1/0.02 -D -Z -I > pepe.cpt

gmt psxy -X0.0 -Y20 -T -K $RJFLAG  >  $FNAMEOUT

cdo gtc,-1 cor-DJF.grd mask.grd
cdo ifthen mask.grd cor-DJF.grd kk.grd
gmt psclip /home/navarro/Trabajos/MOBILAR/DATA/suiza.xy $RJFLAG $OK >> $FNAMEOUT
gmt grdimage  kk.grd?$varname[0] -R0/186/0/130 -JX${width}c/${height}c -Cpepe.cpt $OK  >> $FNAMEOUT
gmt psclip -C $RJFLAG $OK >> $FNAMEOUT
gmt psxy /home/navarro/Trabajos/MOBILAR/DATA/suiza.xy -Wthick,black $RJFLAG $OK -Bnwse+t"DJF" --MAP_TITLE_OFFSET=-1 >> $FNAMEOUT

gmt psxy -X10 -Y0 -T -K -O $RJFLAG  >>  $FNAMEOUT

cdo gtc,-1 cor-MAM.grd mask.grd
cdo ifthen mask.grd cor-MAM.grd kk.grd
gmt psclip /home/navarro/Trabajos/MOBILAR/DATA/suiza.xy $RJFLAG $OK >> $FNAMEOUT
gmt grdimage  kk.grd?$varname[0] -R0/186/0/130 -JX${width}c/${height}c -Cpepe.cpt $OK  >> $FNAMEOUT
gmt psclip -C $RJFLAG $OK >> $FNAMEOUT
gmt psxy /home/navarro/Trabajos/MOBILAR/DATA/suiza.xy -Wthick,black $RJFLAG $OK -Bnwse+t"MAM" --MAP_TITLE_OFFSET=-1 >> $FNAMEOUT


gmt psxy -X-10 -Y-8 -T -K -O $RJFLAG  >>  $FNAMEOUT

cdo gtc,-1 cor-JJA.grd mask.grd
cdo ifthen mask.grd cor-JJA.grd kk.grd
gmt psclip /home/navarro/Trabajos/MOBILAR/DATA/suiza.xy $RJFLAG $OK >> $FNAMEOUT
gmt grdimage  kk.grd?$varname[0] -R0/186/0/130 -JX${width}c/${height}c -Cpepe.cpt $OK  >> $FNAMEOUT
gmt psclip -C $RJFLAG $OK >> $FNAMEOUT
gmt psxy /home/navarro/Trabajos/MOBILAR/DATA/suiza.xy -Wthick,black $RJFLAG $OK -Bnwse+t"JJA" --MAP_TITLE_OFFSET=-1 >> $FNAMEOUT


gmt psxy -X10 -Y0 -T -K -O $RJFLAG  >>  $FNAMEOUT

cdo gtc,-1 cor-SON.grd mask.grd
cdo ifthen mask.grd cor-SON.grd kk.grd
gmt psclip /home/navarro/Trabajos/MOBILAR/DATA/suiza.xy $RJFLAG $OK >> $FNAMEOUT
gmt grdimage  kk.grd?$varname[0] -R0/186/0/130 -JX${width}c/${height}c -Cpepe.cpt $OK  >> $FNAMEOUT
gmt psclip -C $RJFLAG $OK >> $FNAMEOUT
gmt psxy /home/navarro/Trabajos/MOBILAR/DATA/suiza.xy -Wthick,black $RJFLAG $OK -Bnwse+t"SON" --MAP_TITLE_OFFSET=-1 >> $FNAMEOUT

gmt psxy -X-10 -Y0 -T -K -O $RJFLAG  >>  $FNAMEOUT

gmt psscale -Cpepe.cpt -R0/1/0/1 -JX20c -DJBC+w15c/.5c+h+e.5c+o0/0.5c $OK -B+l"correlation">> $FNAMEOUT

gmt psxy -T $RJFLAG -O >> $FNAMEOUT

gmt psconvert -Tf -A $FNAMEOUT 

rm $FNAMEOUT
