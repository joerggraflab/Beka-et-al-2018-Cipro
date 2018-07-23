#!/usr/bin/perl 



%Blast_Target=();

while(defined($file=glob("*.bla")))
{
	@parts=split(/\./,$file);
	#print "$file\n";
	
	if (exists $Blast_Target{$parts[0]})
	{
	}	
	else
	{
		$Blast_Target{$parts[0]}=();
	}
		open(IN, "< $file") or die "cannot open $file:$!"; #assigns filehandle IN to filename or dies
		while(defined($line=<IN>))
		{
			if ($line=~/^#/) #Checks if first character of line is "#" If so then split line on "|"
			{
				if ($line =~ m/Database/)
				{
					@Database=split(/\s/,$line);	
				}
			}
			else
			{
				chomp($line);
				$Blast_Target{$parts[0]} .= "$Database[2]\t$line"; 
				$Blast_Target{$parts[0]} .= "\n"; 
				#print "$seq\n";
			}		
			
			#print "$Blast_Target{$parts[0]}\n";
		}
		$Blast_Target{$parts[0]} .= "\n";
		close (IN);		
}


	@Query_Keys=();
	@Query_Keys=keys(%Blast_Target); #create array of keys to feed into the next loop

	#foreach $r (@Query_Keys)
	#{
	#	print "$r\n";
	#	print "$Blast_Target{$r}\n";
	#}


	foreach $key (@Query_Keys)
	{
		open (OUT, ">$key.bla.cat") or die "Could not create newfile $!\n";	
		print OUT "Genome,\tQuery id,\tSubject id,\t% identity,\talignment length,\tmismatches,\tgap openings,\tq. start,\tq. end,\ts. start,\ts. end,\te-value,\tbit score\n";
		print OUT "$Blast_Target{$key}\n";
		close (OUT);
	}