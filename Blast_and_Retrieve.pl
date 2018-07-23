#Need: .bla output

#grab Database: <genome.faa/.fna>
#need 2nd field (Subject ID)
#need 1st field as name for output file

#grep subject ID against genome. Output to file named as parsed 1st field.

#Handles RAST annotation ouitput files (.faa & .fna) and Prodigal (fasta header of >contig##_##_##) .faa & fna annotation



%Queries_To_Look_Up=();

while(defined($file=glob("*.bla")))
{
	$tophit = 'F';
	$Subject_ID=();
	open(IN, "< $file") or die "cannot open $file:$!"; #assigns filehandle IN to filename or dies
	while(defined($in_line=<IN>))
	{
		
		#print "$in_line\n";
		if ($in_line=~/^#/) #Checks if first character of line is "#" 
		{
			if ($in_line =~ m/Database/)
			{
				$DB_Name = ();
				@Database=();
				@Source_Genome=();
				@Database=split(/\s/,$in_line);	
				@Source_Genome=split(/\./,$Database[2]);
				$Genome_Type=$Source_Genome[1];
				$DB_Name = $Database[2];
				#print "Genome Type: $Genome_Type\n";
				#print "DB_Name: $DB_Name\n";
			} #if line has Database
			elsif ($in_line =~ m/# Query/)
			{
				@Query1=();
				@Query2=();
				@Query1 = split(/\s/,$in_line);
				@Query2 = split(/\|/,$Query1[2]);
				$Subject_ID=$Query2[0];
				#print "Subject_ID: $Subject_ID\n";
			} #if line has Query
		} #if line starts w/#
		elsif ($tophit eq 'F')
		{
			$tophit = 'T';
			@Blast_Result=split(/\t/,$in_line);
			if ($Genome_Type =~ m/faa/)
			{
				#print "$Genome_Type\n";
				if ($Blast_Result[10] <= 1E-10)
				{
					#print "$Blast_Result[10]\n";
					$Accession = $Blast_Result[1];
					if ($Accession =~ m/"contig"/g)
					{
						$Queries_To_Look_Up{$Subject_ID}=$Accession;
					}
					else
					{
						#@DB_ID_Num = split(/\_/,$Accession);
						#$Query = $Blast_Result[0];
						#@Subject = split(/\|/,$Query);
					
						$Queries_To_Look_Up{$Subject_ID}="$Blast_Result[1]\|$DB_Name"; 
						#print "Queries_To_Look_Up{$Subject_ID}: $Queries_To_Look_Up{$Subject_ID}\n";
					}
				}
				
			} #if faa
			elsif ($Genome_Type =~ m/fna/)
			{
				#print "$Genome_Type\n";
				if ($Blast_Result[10] <= 1E-20)
				{
					#print "$Blast_Result[10]\n";
					$Accession = $Blast_Result[1];
					if ($Accession =~ m/"contig"/g)
					{
						$Queries_To_Look_Up{$Subject_ID}=$Accession;
					}
					else
					{
						#@DB_ID_Num = split(/\_/,$Accession);
						#$Query = $Blast_Result[0];
						#@Subject = split(/\|/,$Query);
					
						$Queries_To_Look_Up{$Subject_ID}="$Blast_Result[1]\|$DB_Name"; 
						#print "Queries_To_Look_Up{$Subject_ID}: $Queries_To_Look_Up{$Subject_ID}\n";
					}
				}
				
			} #if fna
		} #elsif tophit eq 'F'
		elsif ($tophit eq 'T') #if tophit loop else
		{
		}
#		} #else - not line starting w/#
		
	} #while line from $line in this .bla
	
	@Look_Up_Keys = ();
	@Look_Up_Keys = keys(%Queries_To_Look_Up);
	foreach $key (@Look_Up_Keys)
	{
	#print "$key\n";
		$DB_Type = ();
		$DB_IDNum_and_Name = ();
		$DB_IDNum = ();
		$DB_to_Lookup = ();
		@Split_Type = ();
		@Isolate_DB = ();
		#@Split_Type = split(/\./,$Queries_To_Look_Up{$key});
		#print "$Queries_To_Look_Up{$key}\n";
		#$DB_Type = $Split_Type[1]; #Isolate the DB type used as being protein (faa) of nucleotide (fna)
		#print "DB_Type: $DB_Type\n";
		@DB_IDnum_and_Name = split(/\|/,$Queries_To_Look_Up{$key});
		@Isolate_DB = split(/\./,$DB_IDnum_and_Name[1]);
		$DB_Type = $Isolate_DB[1];
		#print "DB_Type: $DB_Type\n";
		$DB_to_Lookup = $DB_IDnum_and_Name[1];
		#print "DB_to_Lookup: $DB_to_Lookup\n";
		$DB_IDnum = $DB_IDnum_and_Name[0];
		#print "DB_IDnum: $DB_IDnum\n";
		
		if ($DB_Type =~ m/fna/)
		{
			#print "DB_Type: $DB_Type\n";
			open (OUT, ">$key.$DB_to_Lookup.ffn");
			#print "$key.$DB_to_Lookup.ffn\n";
		}	
		elsif ($DB_Type =~ m/faa/)
		{
			#print "DB_Type: $DB_Type\n";
			open (OUT, ">$key.$DB_to_Lookup.pfa");
		} 
		
		open (GENOME_DB, "< $DB_to_Lookup") or die "cannot open $Queries_To_Look_Up{$key}";
		$target = "0";
		%Blast_Query = ();
		while(defined($line=<GENOME_DB>))
		{
			if ($line =~ /^>\d+\.\d+\.peg\.\d+/) #RAST file headers
			{
			#print "Its RAST\n";
				if ($line =~ m/$DB_IDnum$/) #Is the line a > followed by the accession being searched for
				{
				#print "Matched header:  $DB_IDnum\n";
					$target = "1";
					$seq = ();
					$Header = ();
					chomp($line);
					$Header = $line;
					$Blast_Query{$Header}; #Create Hash key for the header	
					#print "Blast_Query{Header}: $Blast_Query{$Header}\n";
				} #End of if line header matches Accession
				else
				{
					$target = "0";
				}
			}
			elsif ($line =~ m/^>/) #Prodigal file headers
			{
				if ($line =~ m/$DB_IDnum/)
				{
				
					$target = "1";
					$seq = ();
					$Header = ();
					chomp($line);
					$Header = $line;
					$Blast_Query{$Header}; #Create Hash key for the header	
					#print "Blast_Query{Header}: $Blast_Query{$Header}\n";
				}
				else
				{
					$target = "0";
				}
			}
			elsif ($target =~ "1")
			{
				chomp($line);
				$seq .= $line;
				#print "$seq";
				$Blast_Query{$Header} = $seq; #Using the header key created above, add sequence info to its value
				#print "Blast_Query{Header}: $Blast_Query{$Header}\n";
				#print "$seq\n";
			} #End of elsif
		} #End of While line is defined loop
		
		close(GENOME_DB);
		
		print OUT "$Header $DB_to_Lookup [$key]\n";
		print OUT "$Blast_Query{$Header}\n";
		close (OUT);
		
	} # End of foreach $key loop
	
#	$header_key=();
#	$header_key=keys(%Blast_Query);
#	foreach $header_key (%Blast_Query)
#	{
#		print 
#	} #end foreach header_key loop

} #no more .bla 