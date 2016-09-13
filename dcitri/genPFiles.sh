#! bash

####### genPFiles
##
## Script to create pf files and elements file for Diaphorina Citri Cyc
## It is using interproscan results and GOterms (replace obsolets)
##
## Usage: genPFiles.sh crop gfffile blastfile ecfile interproresults gostoreplace
##
## To see details for each input file
## https://docs.google.com/presentation/d/11vbeAHk0Dn9jLqfrtTDd1mCeWMLtP1q5UTC41l2WItI/edit#slide=id.g131faab02f_0_394
#################

crop=$1
gfffile=$2
blastfile=$3
ecfile=$4
gofile=$5
gotoreplace=$6


# create forlder
mkdir scaf


### to get inf del gff

awk -F $'\t' '{
	split($1, scaf, "|");
 	split($9, des, ";");
	split($9, id, "prot_id:");
	split($9, gene, "NCBI_Gene:");
	split(gene[2], gen, "," );
	gsub("ncbi_desc=","",des[5]);
	gsub("ID=","",des[1]);
	if (length(id[2]) > 0){  print $1 "\t" id[2] "\t"  des[5] "\t"  des[1] "\t" gen[1] "\t" $4 "\t" $5 ;}
}' $gfffile | sort -k1,1  >$gfffile.list


#### GO list

awk -F $'\t' '{
	if (length($14) > 0){  print $1 "\t" $14 ; }
}' $gofile | sort -k1,1 | uniq  >$gofile.list


#order blast 

awk -F $'\t' '{
	 	if ($4 > 00){ 
		if ($3 > 40){ print $0; } }
}' $blastfile  | sort -k1,1 -k11,11 -k 3,3 -k4,4 > $blastfile.filtered.out


perl exons2introns.pl $gfffile  >$gfffile.intron.list


# to general pre results

perl preproc.pl $crop $gfffile $blastfile $ecfile


# split pre result in scaffolds

cp $crop.pre.list scaf

awk -F $'\t' '{
		split($16, scaff, "|");
		print >> scaff[2]; close(scaff[2])
	}' $crop.pre.list 

mv 645* scaf/


# from individual pre processed to PF files

perl writefiles.pl $crop $gfffile $gofile $gotoreplace


# delete blank lines

files="scaf/*.pf"
for f in $files
do
  sed '/^$/d' $f > $f.tmp
  mv  $f.tmp $f
done

# del pre files

rm scaf/645*

