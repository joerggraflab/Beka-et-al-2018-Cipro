#!/usr/bin/perl

use Cwd qw();
$longpath=Cwd::cwd();
@pathnames=split(/\//,$longpath);
$length=scalar @pathnames;
$outfile=$pathnames[$length-1];

%Pres_Abs=();

while(defined($list=glob("*.list")))
{
	open(LIST, "< $list") or die "cannot find Genome list file";
	#%Genome_list=();
	
	while(defined($entry_line=<LIST>))
	{
		push(@Genome, $entry_line);
	}
	
	open (OUT, "> $outfile.txt") or die "Could not create newfile $!\n";

	print OUT "\t\t";
	foreach $h (@Genome)
	{
		chomp ($h);
		print OUT "$h\t";
	}
	print OUT "\n";
	
		while(defined($file=glob("*.cat")))
		{
			@parts=split(/\_/,$file);
			#print "$file\n";
			$ordinal=$parts[0];
			
			%Query_Name=();
			
			foreach $l (@Genome)
			{
				$Pres_Abs{$l} = "X";
			}
		
				open(IN, "< $file") or die "cannot open $file:$!"; #assigns filehandle IN to filename or dies
				while(defined($line=<IN>))
				{
					#print "$line\n";
					if ($line=~/^Genome,/) 
					{
						#print "$line\n";
						@header=split(/\t/,$line);
					}
					elsif ($line =~ /^(\w|\d)/) 
					{
						#print "$line\n";
						@entry_components = ();
						@query=();
						@targeted_db=();

						@entry_components = split(/\t/,$line);
						@targeted_db = split(/\./,$entry_components[0]);
						@query = split(/\|/,$entry_components[1]);
						$query_length = $query[1];
						
						$Query_Name{$l}=$query[0];
			
							if ($targeted_db[1] =~ "faa")
							{
								#print "$targeted_db[1]\n";
								if ($entry_components[11] <= 1E-10)
								{
									if ($Pres_Abs{$targeted_db[0]} =~ "X")
									{
									$Pres_Abs{$targeted_db[0]} = ".";
									#print "$Pres_Abs{$targeted_db[0]}\n";
									}
								}
									
								elsif ($entry_components[11] <= 1E-4)
								{
									if ($Pres_Abs{$targeted_db[0]} =~ "X")
									{
									$Pres_Abs{$targeted_db[0]} = "a";
									#print "$Pres_Abs{$targeted_db[0]}\n";
									}
								}
							}
							
							
							elsif ($targeted_db[1] =~ "fna")
							{
								#print "$targeted_db[1]\n";
								if ($entry_components[11] <= 1E-40)
								{
									if ($Pres_Abs{$targeted_db[0]} =~ "X")
									{
									$Pres_Abs{$targeted_db[0]} = ".";
									#print "$Pres_Abs{$targeted_db[0]}\n";
									}
								}
									
								elsif ($entry_components[11] <= 1E-20)
								{
									if ($Pres_Abs{$targeted_db[0]} =~ "X")
									{
									$Pres_Abs{$targeted_db[0]} = "a";
									#print "$Pres_Abs{$targeted_db[0]}\n";
									}
								}								
							}
					
					} #End Else for non-header line
												
				} #End While IN loop
				close (IN);
					
					$printed_query = ();
					@print_query_parts = ();
					$printed_query = $Query_Name{$l};
					$printed_query =~ s/\_/ /;
					@print_query_parts = split(/\s/, $printed_query);
					print OUT "$print_query_parts[0]\t $print_query_parts[1]\t";
					foreach $a (@Genome)
					{
						print OUT "$Pres_Abs{$a}\t";
					}
					print OUT "\n";
			
		} #End $file=glob *.cat
	
} #End While $list=glob *.list

close (OUT);			
close (LIST);