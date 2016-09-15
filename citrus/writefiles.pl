#!/usr/local/bin/perl
#use strict;
use Data::Dumper;

  my $crop=$ARGV[0];
  my $ecfile=$ARGV[2];
  my $annot=$ARGV[3];
  my $gotoreplace=$ARGV[4];

my %hashGOr;
my %hashIntron;
open FILE5, "$crop.intron.gff" or die;

while (my $line5=<FILE5>) {   
     #chomp;
    (my $contg, my $intron, my $start, my $end, my $sign, my $prot) = split /\t/, $line5;  
    (my $key1,my $idctg) = split /\|/, $contg; 

 	$prot = trim($prot);

    if (length($prot) > 0){
	   		
	   		my $words = "$intron\t$start-$end";
	   		if (exists $hashIntron{$prot}) {
	   			  push @{ $hashIntron{$prot} }, trim($words)  ;
			}
			else{
        		$hashIntron{$prot} = [trim($words)]; 
			}
	}
}

### To get array with new and old GOs

open (GO, "<$gotoreplace") or die ("no such file!");

while(my $linego = <GO>)
{
   chomp;
   (my $old,my $sep, my $new) = split /\t/, $linego;  
    $old =~ s/GO_/GO:/g;
    $new =~ s/GO_/GO:/g;

    if (length(trim($new)) > 0){
      $hashGOr{$old}  = trim($new);
   }
}
print Dumper \%hashGOr;


### To get GOs  ## checked
my %hash4;
my %hashgo;
open FILE4, "$annot" or die;

while (my $line4=<FILE4>) {   
   
   my @protdata = split /\t/, $line4;  

	if (length(trim($protdata[7])) > 0){
	  	my @gos = split /\,/, $protdata[7];

		for my $each (@gos){
			$each = replaceGO($each);
	   		if (exists $hashgo{$protdata[1]}) {  push @{ $hashgo{$protdata[1]} }, "DBLINK\t" . trim($each)  ; }
	 		else{	$hashgo{$protdata[1]} = [ "DBLINK\t" . trim($each) ]; }
		}
	 }
	 $hash4{trim($protdata[1])}   = $protdata[10];

}


### To get EC
	my %hashEC;
	my %hashdb;

	open FILE1, "$crop.pre.out" or die;
	open FILEt, "tremb_citrus.txt" or die;
	open FILEs, "uniprot-plant-sw.tab" or die;

	while (my $line=<FILEt>) {   
	   #  chomp;
	   if (length(trim($line)) > 0){
	          $hashdb{trim($line)} = "tr";   
		}
	}
	while (my $line=<FILEs>) {   
	   if (length(trim($line)) > 0){
	          $hashdb{trim($line)} ="sp";   
		}
	}

	my @listec;

	while (my $line=<FILE1>) {   
     
    my @forec = split /\t/, $line; 
	my $ecvalue = trim($forec[18]);

 	push (@listec, $ecvalue);
	 	if(length(trim($forec[18])) > 0 ){

			my @ecvalue1 = split /\;/, $ecvalue; 
	 		foreach my $ecval (@ecvalue1) {

	   		if (exists $hashEC{$forec[13]}) { push @{ $hashEC{$forec[13]} }, "EC\t" . trim($ecval)  ; }
			else{ $hashEC{$forec[13]} = [ "EC\t" .  trim($ecval) ]; }
			}
		}
	}
 
### Read pre outputs file names

   	my $dir = 'scaf';

    opendir(DIR, $dir) or die $!;

	my @introns ;
	my @gos ;
	my @ecs ;
	my $test ;
	my $prot ;
	my $sali, $salid;
	my $countEC = 0;

	my @reg 
        = grep { 
            /\d+/         # Begins 
	    && -f "$dir/$_"   # and is a file
	} readdir(DIR);

  
### Loop for array to printing out the filenames
	open OUTdat, ">elements.dat" or die;

	foreach my $file (@reg) {

		open OUT, ">scaf/$crop.$file.pf" or die;

	    #start each
	    open FILE6, "scaf/$file" or die;

	    print OUTdat "ID\t" . $crop .".". $file .
	     "\nNAME\t" . $crop .".". $file .
		"\nTYPE\t:CONTIG" .
		"\nCIRCULAR?\tN" .
		"\nANNOT-FILE\t" . $crop .".". $file . ".pf\n" .
		"SEQ-FILE\t".  $crop .".". $file . ".fa\n//\n\n" ;

		$test = 0;
		$prot ='';
		$sali ='';
		$salid = '';
		@introns = ();
		@gos = ();
		@ecs = ();

		while (my $line6=<FILE6>) {
		  #   chomp;
			my @output = split /\t/, $line6; 

			# Evaluate if there is previous result unprinted
			if ( $output[13] ne $prot ) {

				# Verify if there is previous result
				if ($test == 0){	
				  	print OUT $sali ;
				  	if (@introns) { print OUT join("\n", @introns) ; }		  	
				  	if (@ecs) { print OUT "\n" . join("\n", @ecs) ; }
				  	if (@gos) { print OUT "\n" . join("\n", @gos) ; }
				 	print OUT $salid;

					$sali = '';
					$salid = '';
					@introns = ();
					@gos = ();
					@ecs = ();
				}

				@introns = uniq(@{ $hashIntron{$output[13]}});
				@gos =  uniq(@{ $hashgo{$output[13]} });
				@ecs = uniq(@{ $hashEC{$output[13]} });
				my $function = trim($hash4{$output[13]});

			    $sali = "ID	" . $output[13] . "\n" .
			           			"NAME	" . $output[13]  . "\n".
								"SYNONYM	"  . trim($output[17]) . "\n".
			           			"STARTBASE	"  .  $output[20]  . "\n".
								"ENDBASE	"  .  $output[21]  . "\n";
			    $salid =  "\nFUNCTION	"  .  $function.  "\n". "PRODUCT-TYPE	P" ;

				my $db = '';

				if ($hashdb{trim($output[14])}) { $db = $hashdb{trim($output[14])}; }
				else { $db = "tr"; }

				$salid = $salid. "\nGENE-COMMENT	"  .  "Similar to $output[14] (DB=" .  $db . " , EVALUE=". $output[10]  . ", PERC_IDENT=".$output[2] .", ALIGN_LENGTH=" .$output[3]  . ")\n".
								"//" . "\n"   ;
				$test = 0;
			}
			
			# First loop, print if have EC
			if ( $hashEC{trim($output[19])} && $test == 0){
				$countEC++;

			 	@introns = uniq(@{ $hashIntron{$output[13]}});
			 	@gos =  uniq(@{ $hashgo{$output[13]} });
				@ecs = uniq(@{ $hashEC{$output[13]} });
				my $function = trim($hash4{$output[13]});

				print OUT "ID	" . $output[13] ."\n" .
			           			"NAME	" . $output[13]  . "\n".
								"SYNONYM	"  . trim($output[17]) . "\n".
			           			"STARTBASE	"  .  $output[20]  . "\n".
								"ENDBASE	"  .  $output[21]  . "\n";
				if (@introns) { print OUT join("\n", @introns). "\n"; }
				print OUT "FUNCTION	"  .  $function .  "\n". "PRODUCT-TYPE	P" . "\n";
				print OUT join("\n", @ecs) ."\n";
				if (length(@gos)>0) { print OUT  "\n" . join("\n", @gos); }

				my $db ;
				
				if ($hashdb{trim($output[14])}) { $db = $hashdb{trim($output[14])};}
				else { $db = "tr";}

				print OUT "\nGENE-COMMENT	"  .  "Similar to $output[14] (DB=" . $db . ", EVALUE=". $output[10]  . ", PERC_IDENT=".$output[2] .", ALIGN_LENGTH=" .$output[3]  . ")\n".
								"//" . "\n"   ;

				@introns = ();
				@gos = ();
				@ecs = ();
				$test = 1;
			}

			$prot = $output[13];
			$count++ ;	

		}

		# Print remain values in the final part
		if ($test == 0){
			print OUT $sali ;
		  	if (@introns) { print OUT join("\n", @introns) . "\n"; }
		  	if (@ecs) { $countEC++; print OUT join("\n", @ecs) . "\n" ; }
		  	if (@gos) { print OUT join("\n", @gos) . "\n" ; }
			print OUT $salid;

		}

		$sali = '';
		$salid = '';
		@introns = ();
		@gos = ();
		@ecs = ();

		### fin each
		$textfile = "scaf/$crop.$file.pf";
	   	$textfile =~ s/\n+/\n/g;

	}

	print "Total genes with EC: " . $countEC . "\n";

    closedir(DIR);
    exit 0;

### Utils

sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };
sub uniq {
    my %seen;
    grep !$seen{$_}++, @_; } ;

sub replaceGO {
    my $goc = shift; 
    my $go = $goc;
    if(exists $hashGOr{trim($go)}){ $goc = $hashGOr{trim($go)}; print $goc . "\t";};
    return $goc
};
