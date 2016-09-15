
#####

#!/usr/bin/env perl
use strict;

my $exon_lists = {};
my $input=$ARGV[0];

open (IN, "<$input") or die ("no such file!");
      my @protid1;
            my $protid;

while(my $line = <IN>)
{
  next if($line =~ m/^###$/);
#print $line;
  my @gff3 = split(/\t/, $line);
    if($gff3[2] eq "mRNA")
    {
           
     # $protid = $gff3[8] =~ m/prot_id:([^\s;]+)/;
    
     @protid1 = split /Name=([^\s;]+)/, $gff3[8];
       $protid = $protid1[1];
    }
  if($gff3[2] eq "exon")
  {  
    my($mRNAid) = $gff3[8] =~ m/Parent=([^\s;]+)/;
    printf(STDERR "warning: exon has no 'Parent' attribute: %s", $line) unless($mRNAid);

    $exon_lists->{$protid} = [] unless($exon_lists->{$protid});
#    push(@{$exon_lists->{$mRNAid}}, \@gff3);
    push(@{$exon_lists->{$protid}}, \@gff3);

  }
}

foreach my $protid(keys(%$exon_lists))
{
  my @sorted_exons = sort { $a->[3] <=> $b->[3] || $a->[4] <=> $b->[4] } (@{$exon_lists->{$protid}});
  for(my $i = 1; $i < scalar(@sorted_exons); $i++)
  {
    printf("%s\n",
      join("\t",
        $sorted_exons[$i]->[0],
        "INTRON",
        $sorted_exons[$i-1]->[4] + 1,
        $sorted_exons[$i]->[3] - 1,
        $sorted_exons[$i]->[6],
        "$protid"
      )
    );
  }
}
