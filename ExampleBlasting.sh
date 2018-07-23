#!/bin/bash 
#$ -S /bin/bash
#!/bin/env perl
#$ -o /Directory/job.o     # name the output file; %J inserts the current job number
#$ -e /Directory/job.e     # name the error file; %J inserts the current job number
#S -j y

#example shell script that shows where to use the blast, retrieval & sorting scripts
#requires a *.query file with the names of the genes being blasted (i.e. atpD, rpoB...) & a *.list file containing the names of all of the genomes used int the blast searching

cd /Directory
#$ -cwd            # tells GE to execute the job from  the  current  working  directory

#strip the beginning of the of the RAST header that causes difficulties
for filn in *.fna; do sed s/fig\|//g $filn > $filn.fig; done;
rm *.fna;
for x in *.fig;do mv $x $(echo ${x%*.*});done;

#prep databases
for filn in *.fna; do formatdb -i $filn -p F -o T; done;

#run Blast
perl DNA_Blast_tBlastx.pl;

#retrieve hits from databases and sort into folders
perl Blast_and_Retrieve.pl;

mkdir Retrieved_Files;
cp *.ffn ./Retrieved_Files;
cp *.query ./Retrieved_Files;
cp Sort_Retrieved_Hits_ffn.pl ./Retrieved_Files;
cd Retrieved_Files;
perl Sort_Retrieved_Hits_ffn.pl;

#align

cd Concat_fa_files;
mkdir MuscAlign;
cp *.fa ./MuscAlign;
cp *.musc.list ./MuscAlign
cd MuscAlign;
for filn in *.fa; do sed "s/[0-9]*.[0-9]*.peg.[0-9]* //g" $filn|cut -d "." -f 1 > $filn.sed;done
rm *.fa;
for x in *.sed;do mv $x $(echo ${x%*.*});done;
for filn in *.fa; do muscle -in $filn -out $filn.musc; done;
for filn in *.musc; do muscle -refine -in $filn -out $filn.muscII; done;
cd ..; #pull back from MuscAlign -> Concat_fa_files
cd ..; #pull back from Concat_fa_files -> Retrieved_Files
cd ..; #pull back from Retrieved_Files -> root working directory where script started from

#Clean up blast results
perl Blast_Output_Concatenation.pl;
perl Sort_Output_Into_Folders.pl;

#Prep for and create summary file
cp Pres_Abs_Sorter.pl ./Summaries;
cp *.list ./Summaries;
cd Summaries;
perl Pres_Abs_Sorter.pl;
cd ..; #pull back from Summaries -> root directory
