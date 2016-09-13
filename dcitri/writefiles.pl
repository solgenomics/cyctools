#!/usr/bin/perl

=head1 NAME
 writefiles.pl 
 Script to merge all pre processing files to create individuals pf files
=cut

=head1 SYPNOSIS
 writefiles.pl crop gfffile gofile gotoreplacelistfile
 
=head1 DESCRIPTION
Script to merge all pre processing files to create individuals pf files. This is a part of genPFiles pipeline.

=cut

my $crop=$ARGV[0];
my $gfffile=$ARGV[1];
my $gofile=$ARGV[2];
my $gotoreplace=$ARGV[3];

my $dir = 'scaf';
my @introns ;
my @gos ;
my @ecs ;
my $test ;
my $prot ;
my $tmpwrite, $towrite;
my $countEC = 0;
my %hashIntron;
my %hashGO;
my %hashEC;
my %hashGOr;

open FILEGO, "$gofile.list" or die;
open FILEGFF, "$gfffile.intron.list" or die;
open FILEPRE, "$crop.pre.list" or die;
open OUTdat, ">$crop.elements.dat" or die;
opendir(DIR, $dir) or die $!;


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


### To get GOs  

while (my $line4=<FILEGO>) {   
   
   (my $prot,my $go) = split /\t/, $line4;  

	if (length(trim($go)) > 0){
	   		
	 	my @gos = split /\|/, $go;
	   	
	   	for my $each (@gos){
	   		$each = replaceGO($each);
	   		if (exists $hashGO{$prot}) {  push @{ $hashGO{$prot} }, "DBLINK\t" . trim($each)  ; }
			else{	$hashGO{$prot} = [ "DBLINK\t" . trim($each) ]; }
		}
	}
}


### To get introns

while (my $line5=<FILEGFF>) {   
    chomp;
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


### For get ECs array

while (my $line9=<FILEPRE>) {   
    chomp;
    my @forec = split /\t/, $line9; 
	my $ecvalue = trim($forec[18]);

 	if(length(trim($forec[18])) > 0 ){
		
		my @ecvalue1 = split /\;/, $ecvalue; 

	 	foreach my $ecval (@ecvalue1) {
   			if (exists $hashEC{$forec[13]}) { push @{ $hashEC{$forec[13]} }, "EC\t" . trim($ecval)  ; }
			else{ $hashEC{$forec[13]} = [ "EC\t" . trim($ecval) ]; }
		}
	}
}

# Read files in folder 
my @reg 
        = grep { 
            /\d+/         # Begins with a period
	    && -f "$dir/$_"   # and is a file
	} readdir(DIR);


# Loop for printing out the files
foreach my $file (@reg) {

	$test = 0;
	$prot ='';
	$tmpwrite ='';
	$towrite = '';
	@introns = ();
	@gos = ();
	@ecs = ();

	#start each
	open OUT, ">scaf/Diacit_$file.pf" or die;
    open FILEscaf, "scaf/$file" or die;

    #Print elements file
	print OUTdat "ID\t" . $crop ."_". $file .
	     "\nNAME\t" . $crop ."_". $file .
		 "\nTYPE\t:CONTIG" .
		 "\nCIRCULAR?\tN" .
		 "\nANNOT-FILE\t" . $crop ."_". $file . ".pf\n" .
		 "SEQ-FILE\t".  $crop ."_". $file . ".fa\n//\n\n" ;


	while (my $linescaf=<FILEscaf>) {
	    chomp;
		my @output = split /\t/, $linescaf; 

		if ( $output[13] ne $prot ) {

			if ($test == 0){	

			  	print OUT $tmpwrite ;
			  	if (@introns){ print OUT join("\n", @introns); }
			  	if (@ecs) { print OUT "\n" . join("\n", @ecs) ; }
				if (@gos) { print OUT "\n" . join("\n", @gos) ; }
			 	print OUT $towrite;

				$tmpwrite = '';
				$towrite = '';
				@introns = ();
				@gos = ();
				@ecs = ();

			}
			
			@introns = uniq(@{ $hashIntron{$output[13]}});
			@gos =  uniq(@{ $hashGO{$output[13]} });
			@ecs = uniq(@{ $hashEC{$output[13]}});

		    $tmpwrite = "ID\t" . $output[13] . "\n" .
		           		"NAME\t" . $output[13]  . "\n".
						"SYNONYM\t"  . trim($output[17]) . "\n".
		           		"STARTBASE\t"  .  $output[20]  . "\n".
						"ENDBASE\t"  .  $output[21]  . "\n";
 
		    if (length($output[16])>0 ) { $towrite =  "\nFUNCTION\t"  .  $output[16] ; }

		    $towrite = $towrite. "\n". "PRODUCT-TYPE\tP" ;
			$towrite = $towrite. "\nGENE-COMMENT\t"  .  "Similar to $output[14] (DB=" . trim($output[19]) . " , EVALUE=". $output[10]  . ", PERC_IDENT=".$output[2] .", ALIGN_LENGTH=" .$output[3]  . ")\n".
								 "//" . "\n"   ;
			$test = 0;
		}


		if($hashEC{$output[13]} && $test == 0){
			
			$countEC++;
		 	@introns = uniq(@{ $hashIntron{$output[13]}});
		 	@gos =  uniq(@{ $hashGO{$output[13]} });
		 	@ecs = uniq(@{ $hashEC{$output[13]}});

			print OUT "ID\t" . $output[13] . "\n" .
		           	  "NAME\t" . $output[13]  . "\n".
					  "SYNONYM\t"  . trim($output[17]) . "\n".
		           	  "STARTBASE\t"  .  $output[20]  . "\n".
					  "ENDBASE\t"  .  $output[21]  . "\n";

			if (@introns){
				print OUT join("\n", @introns);
				print OUT "\n"; }
			
			if (length($output[16])>0 ) {	print OUT "FUNCTION\t"  .  $output[16] };

			print OUT  "\n". "PRODUCT-TYPE\tP" ;
			
			if (length(@ecs)>0) { print OUT "\n" . join("\n", @ecs); } 

			if (length(@gos)>0) { print OUT "\n" . join("\n", @gos); }

			
			print OUT "\nGENE-COMMENT\t"  .  "Similar to $output[14] (DB=" . trim($output[19]) . ", EVALUE=". $output[10]  . ", PERC_IDENT=".$output[2] .", ALIGN_LENGTH=" .$output[3]  . ")\n".
							"//" . "\n"   ;

			@introns = ();
			@gos = ();
			@ecs = ();
			$test = 1;
		}

		$prot = $output[13];
		$count++ ;	

	}

	if ($test == 0){
		print OUT $tmpwrite;
	  	if (@introns) { print OUT join("\n", @introns); }
		if (@ecs) { $countEC++; print OUT join("\n", @ecs) . "\n" ; }
		if (@gos) { print OUT join("\n", @gos) . "\n" ; }
		print OUT $towrite;
	}

	$tmpwrite = '';
	$towrite = '';
	@introns = ();
	@gos = ();
	@ecs = ();

	### fin each
   
}

print "# Genes with EC: " . $countEC . "\n";

closedir(DIR);
exit 0;



sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };
sub uniq {
    my %seen;
    grep !$seen{$_}++, @_; } ;
sub replaceGO {
    my $goc = shift; 
    my $go = $goc;
 #   $go =~ s/DBLINK\t//g; 
 #   $go = "GO:" . $go; 
    if(exists $hashGOr{trim($go)}){ $goc = $hashGOr{trim($go)}};
    return $goc
};
