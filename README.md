solcyctools
===========

  Perl tool package to create pathologic files (.pf) for genomic and 
transcriptomic projects

* INTRODUCTION:

   Pathways tools is a software to create metabolic pathway databases such as
MetaCyc, EcoCyc or AraCyc (http://biocyc.org/publications.shtml). Nevertheless
this software doesn't use annotation files in standard formats such as GFF3.

   SolCycTools are a package of Perl scripts developed to create the pathologic
files (.PF) accepted by the Pathway Tools software. It also parse annotations
from the Uniprot datasets (SwissProt and Trembl) to enhance the annotations
from the GFF file looking for EC numbers, GO Terms and more comprenhesive 
descriptions.

   These scripts can be used with two different pipelines: 
   A) Genomics (input files: GFF with structural annotations and FASTA with 
      mRNA or proteins).
   B) Trancriptomics (input file: FASTA assembled transcriptome).


1) GENOMICS PIPELINE:

   The genomics pipeline uses a GFF with annotations to create the pathologic
files, so initially the pipeline should be as easy as:

1.1) Easy Approach:

   % gff2pathologic.pl -g species.gff

   For a gff file with, for example 5 chromosomes (noted as 1,2,3,4 and 5), it 
will create 5 files: out_1.pf, out_2.pf, out_3.pf, out_4.pf and out_5.pf.

   This script will search some meaningfull annotation for each of the 'gene'
features in the GFF file, in the 'Note' tag. Specifically it will try to find
an EC number in this field to create a pathologic entry.

  A gff line will be converted according to:

   +--------------------------+-----------------------------------------+
   | GFF3                     |    Pathologic                           |
   +--------------------------+-----------------------------------------+
   | - Column 1: "seqid"      =>   Output files (one per file).         |
   | - Column 2: "source"     =>   Ignored.                             |
   | - Column 3: "type"       =>   Selected lines through -t parameter. |
   | - Column 4: "start"      =>   STARTBASE for each entry             |
   | - Column 5: "end"        =>   ENDBASE for each entry               |
   | - Column 6: "score"      =>   Ignored.                             |
   | - Column 7: "strand"     =>   Switch STARTBASE <-> ENDBASE.        |   
   | - Column 8: "phase"      =>   Ignored.                             |
   | - Column 9: "attributes" =>                                        | 
   |            + ID          ->   ID                                   |
   |            + Name        ->   NAME                                 |
   |            + Alias       ->   SYNONYM                              |
   |            + Note        ->   GENE-COMMENT                         |
   +---------------------------+----------------------------------------+

   Finally if you need to create one FASTA file per sequence, you can use the
script: 

   % fasta_splitter.pl -f species.fasta.

   Also you can create the genetic-element.dat file using the script:

   % create_gefile.pl -b out


   Nevertheless it is possible that your GFF file doesn't have any useful
annotation (or perhaps you want to enhance it).

1.2) Complete Approach:

  It involves the functional reannotation and use of the new annotation to
enhance the EC/meaninful description assigment to each of the sequences during
the process.