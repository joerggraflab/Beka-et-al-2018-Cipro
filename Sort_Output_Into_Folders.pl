#!/usr/bin/perl 
#Program sorts the output of Blast_DNA_OutInFile.pl and Blast_Prot_OutInFile.pl into folders
#Folders are created for each *.fa and contain the query *.fa and each blast return for it.


system("mkdir Summaries");
	
while(defined($files=glob("*.cat")))
{
	@filename_comps=split(/\./,$files);
	$Summaries{$filename_comps[0]}="True";
	#$pathway=system("pwd");
	#print "$pwd\n";
	$b=$pwd."Summaries";
	system("mv $files $b");
}



%Accessions=();

while(defined($file=glob("*.fa"))) 
{
	#Bring in each *.fa, which is an output of the Blast programs
	@filename_components=split(/\./,$file);
	system("mkdir $filename_components[0]"); 
	#Create a folder with the name of the accession number (file format is accession.fa)
	$Accessions{$filename_components[0]}="True";
	#Add an entry to the hash with the key being the accession number
}

@Accession_keys=keys(%Accessions);

#while ( ($k,$v) = each %Accessions ) {
#    print "$k => $v\n";
#}

foreach $keys (@Accession_keys)
{
	#print "$keys\n";
	while(defined($filein=glob("$keys.*")))
	{
		#print "$filein\n";
		#$path=system("pwd");
		#print "$pwd\n";
		$a=$pwd.$keys;
		system("mv $filein $a");
	}
}

#foreach $keys (%Accession_keys)
#{
#	print "$keys\n";
#	while(defined($filein=glob("$keys.fa")))
#	{
#		system("mv $filein > $filename_components[0]");
#	}
#}
