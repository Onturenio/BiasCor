################################################################################
# GMT SCRIPT TO PLOT CLIMATOLOGICAL PRECIPITATION
################################################################################

FNAMEIN=$1
FNAMEOUT=$2
data=$3
seas=$4
varname=`ncdump -h $FNAMEIN | grep float| grep time | awk '{print $2}' | awk -F\( '{print $1}'`

# This defines the proyection and the size of the map
RFLAG="-R5.821136/45.66386/10.66321/48.00829r"
RJFLAG="${RFLAG} -JL8.781/47.16/47.16/47.16/10c"

# Some other common features
NOLAKES="-A100/0/1"
OK="-O -K"

if [[ $seas == "annual" ]]; then
  gmt makecpt -CGMT/YlGnBu_09.cpt -T0/3000/300 -D -Z  > pepe.cpt
else
  gmt makecpt -CGMT/YlGnBu_09.cpt -T0/1000/100 -D -Z > pepe.cpt
fi

gmt psxy -X1.0 -Y3 -T -K $RJFLAG  >  $FNAMEOUT
gmt set COLOR_NAN white
width=$(gmt mapproject $RJFLAG -Ww)
height=$(gmt mapproject $RJFLAG -Wh)

gmt psclip /home/navarro/Trabajos/MOBILAR/DATA/suiza.xy $RJFLAG $OK >> $FNAMEOUT
gmt grdimage  $FNAMEIN?$varname[0] -R0/186/0/130 -JX${width}c/${height}c -Cpepe.cpt $OK  >> $FNAMEOUT
gmt psclip -C $RJFLAG $OK >> $FNAMEOUT

gmt psxy /home/navarro/Trabajos/MOBILAR/DATA/suiza.xy -Wthick,black $RJFLAG $OK -Bnwse+t"$data $seas" --MAP_TITLE_OFFSET=0>> $FNAMEOUT

gmt psscale -Cpepe.cpt -R -J -DJBC+w10c/.4c+h+e+o0/0.5c $OK -B+l"prec. (mm)">> $FNAMEOUT

gmt psxy -T $RJFLAG -O >> $FNAMEOUT

gmt psconvert -Tf -A $FNAMEOUT 

rm $FNAMEOUT

# removing trash
rm -rf field.asc pepe* *grd
