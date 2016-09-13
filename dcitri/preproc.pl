#!/usr/local/bin/perl

=head1 NAME
 preproc.pl 
 Script to create pre processing files to create individuals pf files
=cut

=head1 SYPNOSIS
 preproc.pl crop gfffile blastfile ecfile
 
=head1 DESCRIPTION
Script to create pre processing files to create individuals pf files. This is a part of genPFiles pipeline.

=cut

use strict;
use Data::Dumper qw(Dumper);
use List::Util 'max';

use warnings;
my $crop=$ARGV[0];
my $gfffile=$ARGV[1];
my $blastfile=$ARGV[2];
my $ecfile=$ARGV[3];

my @blast;
my @prot;
my %hashinfo;
my %hash_scf;
my %hashEC;

open FILEEC, "$ecfile" or die;
open preOUT, ">$crop.pre.list" or die;
open FILEGFF, "$gfffile.list" or die;
open FILEBLAST, "$blastfile.filtered.out" or die;


#To get info and function from GFF file

while (my $line3=<FILEGFF>) {   
    
   chomp;
   
   (my $scf,my $prot, my $desc, my $id, my $gene, my $start, my $end) = split /\t/, $line3;  
	   if (length(trim($prot)) > 0){
	   	$hashinfo{$prot}{scf}   = $scf;
	   	$hashinfo{$prot}{desc}   = $desc;
	   	$hashinfo{$prot}{id}   = $id;
		$hashinfo{$prot}{gen}   = $gene;
		$hashinfo{$prot}{start}   = $start;
		$hashinfo{$prot}{end}   = $end;
	   	$hash_scf{$scf}   = $prot;
	}
}


### To get EC
    
while (my $line=<FILEEC>) {   
   chomp;
   (my $word1,my $word2) = split /\t/, $line;  
   if (length(trim($word2)) > 0){
          $hashEC{$word1} = trim($word2);   
	}
}


### To merge everything and write pre results

while (my $line2=<FILEBLAST>) {   
	chop $line2;

	@blast = ();
	@prot = ();
    @blast = split /\t/, $line2;  

   (my $db, my $ort) = split /\|/, $blast[1]; 	#split ortolog  

    @prot = split /\|/, $blast[0];  			#split prot name
	
	print preOUT $line2 . "\t".  trim($hashinfo{trim($prot[3])}{id}) ."\t". trim($prot[3]) ."\t" . $ort  . "\t" . $hashinfo{$prot[3]}{scf}  . "\t" . 
		$hashinfo{$prot[3]}{desc} . "\t" . trim($hashinfo{$prot[3]}{gen}) . "\t". $hashEC{$ort} ."\t" . $db .  "\t" . 
		trim($hashinfo{$prot[3]}{start}) .  "\t" . trim($hashinfo{$prot[3]}{end}) .  "\t." .
		 "\n" ;
}

sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };
sub uniq {
    my %seen;
    grep !$seen{$_}++, @_; } ;




