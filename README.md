solcyctools
===========

  Perl tool package to create pathologic files (.pf) for genomic and 
transcriptomic projects

## 0) INTRODUCTION: ##

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


## 1) GENOMICS PIPELINE: ##

   The genomics pipeline uses a GFF with annotations to create the pathologic
files, so initially the pipeline should be as easy as:

### 1.1) Easy Approach: ###

```
   % gff2pathologic.pl -g species.gff
```

   For a gff file with, for example 5 chromosomes (noted as 1,2,3,4 and 5), it 
will create 5 files: out_1.pf, out_2.pf, out_3.pf, out_4.pf and out_5.pf.

   This script will search some meaningfull annotation for each of the 'gene'
features in the GFF file, in the 'Note' tag. Specifically it will try to find
an EC number in this field to create a pathologic entry.

  A gff line will be converted according to:

<table>
   <tr>
     <td>GFF3</td><td>Pathologic</td>
   </tr>
   <tr>
     <td>Column 1: "seqid"</td><td>Output files (one per file).</td>
   </tr>
   <tr>
     <td>Column 2: "source"</td><td>Ignored.</td>
   </tr>
   <tr>
     <td>Column 3: "type"</td><td>Selected lines through -t parameter</td>
   </tr>
   <tr>
     <td>Column 4: "start"</td><td>STARTBASE for each entry</td>
   </tr>
   <tr>
     <td>Column 5: "end"</td><td>ENDBASE for each entry</td>
   </tr>
   <tr>
     <td>Column 6: "score"</td><td>Ignored.</td>
   </tr>
   <tr>
     <td>Column 7: "strand"</td><td>Switch STARTBASE <-> ENDBASE.</td> 
   </tr>
   <tr>
     <td>Column 8: "phase"</td><td>Ignored.</td>
   </tr>
   <tr>
     <td>Column 9: "attributes"</td><td>See below</td>
   </tr>
   <tr>
     <td>ID</td><td>ID</td>
   </tr>
   <tr>
     <td>Name</td><td>NAME</td>
   </tr>
   <tr>
     <td>Alias</td><td>SYNONYM</td>
   </tr>
   <tr>
     <td>Note</td><td>GENE-COMMENT and EC</td>
   </tr>   
</table>

   Finally if you need to create one FASTA file per sequence, you can use the
script: 

```
   % fasta_splitter.pl -f species.fasta.
```

   Also you can create the genetic-element.dat file using the script:

```
   % create_gefile.pl -b out
```

   Nevertheless it is possible that your GFF file doesn't have any useful
annotation (or perhaps you want to enhance it).

### 1.2) Complete Approach: ###

  It involves the functional reannotation and use of the new annotation to
enhance the EC/meaninful description assigment to each of the sequences during
the process.

