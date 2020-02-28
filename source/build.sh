#!/bin/sh
set -e



echo "Generating VFs"
mkdir -p ../fonts/vf
fontmake -m Raleway-Roman.designspace -o variable --output-path ../fonts/vf/Raleway[wght].ttf
fontmake -m Raleway-Italic.designspace -o variable --output-path ../fonts/vf/Raleway-Italic[wght].ttf

rm -rf master_ufo/ instance_ufo/ instance_ufos/*



vfs=$(ls ../fonts/vf/*\[wght\].ttf)

echo "Post processing VFs"
for vf in $vfs
do
	gftools fix-dsig -f $vf;

	echo "TTF AH"

	ttfautohint --stem-width-mode nnn $vf "$vf.fix";
	mv "$vf.fix" $vf;
done



echo "Fixing VF Meta"
gftools fix-vf-meta $vfs;

echo "Dropping MVAR"
for vf in $vfs
do
	mv "$vf.fix" $vf;
	ttx -f -x "MVAR" $vf; # Drop MVAR. Table has issue in DW
	rtrip=$(basename -s .ttf $vf)
	new_file=../fonts/vf/$rtrip.ttx;
	rm $vf;
	ttx $new_file
	rm $new_file
done

echo "Fixing Hinting"
for vf in $vfs
do
	gftools fix-hinting $vf;
	mv "$vf.fix" $vf;
done




echo "Generating Static fonts"
mkdir -p ../fonts
fontmake -m Raleway-Roman.designspace -i -o ttf --output-dir ../fonts/ttf/
fontmake -m Raleway-Italic.designspace -i -o ttf --output-dir ../fonts/ttf/
fontmake -m Raleway-Roman.designspace -i -o otf --output-dir ../fonts/otf/
fontmake -m Raleway-Italic.designspace -i -o otf --output-dir ../fonts/otf/


echo "Post processing"
ttfs=$(ls ../fonts/ttf/*.ttf)
for ttf in $ttfs
do
	gftools fix-dsig -f $ttf;
	ttfautohint $ttf "$ttf.fix";
	mv "$ttf.fix" $ttf;
done

for ttf in $ttfs
do
	gftools fix-hinting $ttf;
	mv "$ttf.fix" $ttf;
done

rm -rf master_ufo/ instance_ufo/ instance_ufos/*

