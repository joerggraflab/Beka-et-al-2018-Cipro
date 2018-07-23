#!/usr/bin/perl -w

#Program takes the Protein sequences of the genes in the GIs predicted by Island Viewer and uses them as Blast query against the Halorubrum
#genomes available. It selects a query as part of a loop and then blasts it against each genome
#in sequence

while(defined($file=glob("*.ffn")))
{
	#@parts=split(/\_/,$file);
	print "$file\n";
	#$Source=$parts[1];
	
	%Blast_Query=();
	
		
		open(IN, "< $file") or die "cannot open $file:$!"; #assigns filehandle IN to filename or dies
		while(defined($line=<IN>))
		{
			if ($line=~/^>/) #Checks if first character of line is ">" If so then split line on "|"
			{
				$seq=();
				#@components=(); #blank array which will contain the split elements of the header line
				#@components=(split/\|/,$line); #split header line on the "|"
				@Header1=();
				@Header1=(split/\[/,$line);
				#@Header2=();
				$GeneName=$Header1[1];
				chomp($GeneName);
				$GeneName =~ s/\s\(.*\)//g;
				$GeneName =~ s/\]//;
				$GeneName =~ s/\s//g;
				$GeneName =~ s/\///g;
				#$GeneName =~ s/\/\_/g;
				
				$Accession= $GeneName; #Take the Accession number
				#print "$Accession\n";
				$Blast_Query{$Accession} = $seq; #Create Hash key for the accession number
				#foreach $q (keys(%Blast_Query))
				#{
				#	print "$q \n"
				#}
			}
			else
			{
				chomp($line);
				$seq .= $line;
				#print "$seq";
				$Blast_Query{$Accession} = $seq; #Using the Accession key created above, add sequence info to its value
				#print "$seq\n";
			}		
			
		}
		close (IN);		
	

	@Query_Keys=();
	@Query_Keys=keys(%Blast_Query); #create array of keys to feed into the next loop
	
	foreach $p (@Query_Keys)
	{
		print "$p\n";
	#	print "$Blast_Query{$p}\n";
	}
	
	foreach $r (@Query_Keys)
	{
		open (OUT, ">$r.fa") or die "Could not create newfile $!\n";
		$hash_value_length=length($Blast_Query{$r});
		print OUT "\>$r\|$hash_value_length\n";
		print OUT "$Blast_Query{$r}\n";
		close (OUT);
	}
	
	
	#foreach $t (@Query_Keys)
	#{
	#	open (OUT, ">$t.fa")||die "can't open newfile $!\n";
	#	print OUT "\>$t \n";
	#	print OUT "$Blast_Query{$t}\n";
		#Creates Outfiles for each accessionnumber/entry named as <Accession number w/fa ending
		#File contains ">"infront of the accession for the header line with the sequence below
	#}
	
	while(defined($fafile=glob("*.fa")))
	{
		@accession_num=(split/\./,$fafile);
		while(defined($database=glob("*.fna"))) 
		#Haloru.*.fna specifies the different fna files converted via formatdb
		{
			@dbparts=split(/\_/,$database);
			$dbname="$dbparts[1]_$dbparts[2]";
			system("blastall -p tblastx -i $fafile -d $database -e 1E-4 -m 9 -K 5 -v 5 -o $accession_num[0].$dbname.bla");
		#Calls blastall on the cluster and runs a nucleotide blast against the database selected above.
		#output will be long and clunky, but specifies the query and db used
		}
	}
}

exit;
	