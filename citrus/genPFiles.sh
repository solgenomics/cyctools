#! bash
####### genPFiles
##
## Script to create pf files and elements file for Citrus Cyc
## It is using interproscan results and GOterms (replace obsolets)
##
## Usage: genPFiles.sh crop gfffile blastfile ecfile annotationsfile gostoreplace
##
## To see details for each input file
## https://docs.google.com/presentation/d/11vbeAHk0Dn9jLqfrtTDd1mCeWMLtP1q5UTC41l2WItI/edit#slide=id.g131faab02f_0_394
#################

crop=$1
gfffile=$2
blastfile=$3
ecfile=$4
annot=$5
gotoreplace=$6

### to get inf del gff

awk -F $'\t' '{
#	split($1, scaf, "|");
 	split($9, des, ";");
	split($9, id, "prot_id:");
	split($9, gene, "Parent=");
	split(gene[2], gen, "," );
	gsub("ncbi_desc=","",des[5]);
	gsub("ID=","",des[1]);
	#if (length(id[2]) > 0){  print $1 "\t" id[2] "\t"  des[5] "\t"  des[1] "\t" gene[0];}
	if ($3 == "mRNA"){ print $1 "\t" des[1] "\t" gene[2] "\t" $4 "\t" $5; }
}' $gfffile | sort -k1,1  >$crop.gff.list


# #### GO list

# awk -F $'\t' '{
# 	if (length($14) > 0){  print $1 "\t" $14 ; }
# }' ncbi_protein_interpro.tsv | sort $1 | uniq $1  >ncbi_protein_interpro_GO.list

# #order blast  and filter the best score

awk -F $'\t' '{
	 	if ($4 > 00){ 
		if ($3 > 40){ print $0; } }
}' $blastfile  | sort -k1,1 -k11,11 -k 3,3 -k4,4 > $crop.blast.list

perl exons2introns.pl $gfffile  >$crop.intron.gff

perl preproc.pl $crop $ecfile $annot

cp $crop.pre.out scaf


 awk -F $'\t' '{
 		print >> $16; close($16)
 }' $crop.pre.out 
mv scaff* scaf/

perl writefiles.pl $crop $crop.pre.out $ecfile $annot $gotoreplace


files="scaf/*.pf"
for f in $files
do
  sed '/^$/d' $f > $f.tmp
  mv  $f.tmp $f
done




