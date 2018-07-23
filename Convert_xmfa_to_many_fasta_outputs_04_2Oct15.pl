#!/usr/bin/perl

while(defined($file=glob("*.xmfa")))
{
	
	open(IN, "< $file") or die "cannot open $file:$!";
	open(TRANS_OUT, "> $file.key") or die "cannot open TransKey.key:$!";
	open(LIST_OUT, "> $file.list") or die "cannot open $file.list:$!";
	%sequence_hash = ();
	$k = 1;
	
	#print "$file\n";
	while(defined($line=<IN>))
	{
		chomp($line);
		if ($line=~/^#/)
		{
			#print "line starts with #\n";
			if ($line=~/^#Annotation[0-9]*File/)
			{
				if ($line =~ /\//g)
				{
					#print "found /\n";
					@annote_line = ();
					$seq_number = ();
					$genome_name = ();
					@annote_back_line = split(/\//, $line);
					$genome_name = $annote_back_line[-1];
					@annote_line = split(/\t/, $line);
					$seq_number = $annote_line[0];
					$seq_number =~ s/#Annotation//;
					$seq_number =~ s/File//;
					print TRANS_OUT "$seq_number\t$genome_name\n";
					$sequence_hash{$genome_name} = ();
				}		
				else
				{
					#print "Entered Annotation loop\n";
					#print "$line\n";
					@annote_line = ();
					$seq_number = ();
					$genome_name = ();
					@annote_line = split(/\t/, $line);
					$seq_number = $annote_line[0];
					$seq_number =~ s/#Annotation//;
					$seq_number =~ s/File//;
					#print "seq_number = $seq_number\n"; 
					$genome_name = $annote_line[1];
					#print "genome_name = $genome_name\n";
					print TRANS_OUT "$seq_number\t$genome_name\n";
					$sequence_hash{$genome_name} = ();
				}
			}
		}
		elsif ($line=~/^>/) #Checks if first character of line is ">" If so then split line on "|"
		{
			if ($line =~ /\//g)
			{
				#print "line starts with >\n";
				@header = ();
				$seq_name = ();
				@path_header = ();
				@header = split(/\s/,$line);
				#print "$header[3]\n";
				@path_header = split(/\//,$header[-1]);
				$seq_name = $path_header[-1];
			}
			else
			{
				#print "line starts with >\n";
				@header = ();
				$seq_name = ();
				@header = split(/\s/,$line);
				#print "$header[3]\n";
				$seq_name = $header[3];
			}
		}
		elsif ($line=~/=/)
		{
			open (FASTA_OUT, "> $file.$k.fasta") or die "cannot open $file.$k.fasta:$!";	
			print LIST_OUT "$file.$k.fasta\n";
			@Query_Keys=();
			@Query_Keys=keys(%sequence_hash); #create array of keys to feed into the next loop
	
			foreach $p (@Query_Keys)
			{
				print FASTA_OUT ">$p\n";
				print FASTA_OUT "$sequence_hash{$p}\n";
			}		
			close (FASTA_OUT);
			%sequence_hash = ();
			$k += 1;
		}
		else
		{
			$sequence_hash{$seq_name} .= $line;
		}
	
	} #end of this xmfa file
	close (IN);
	close (TRANS_OUT);
	
	open (FASTA_OUT, "> $file.$k.fasta") or die "cannot open $file.fasta:$!";	
	@Query_Keys=();
	@Query_Keys=keys(%sequence_hash); #create array of keys to feed into the next loop
	
	foreach $p (@Query_Keys)
	{
		print FASTA_OUT ">$p\n";
		print FASTA_OUT "$sequence_hash{$p}\n";
	}
	close (FASTA_OUT);
	close (LIST_OUT);
}