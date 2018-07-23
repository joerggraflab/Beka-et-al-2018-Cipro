#!/usr/bin/perl -w

while(defined($file=glob("*.query")))
{
	open(IN, "< $file") or die "cannot open $file:$!"; #assigns filehandle IN to filename or dies
	@temp = (split/\./,$file);
	$temp2 = $temp[0];
	open (OUT, ">$temp2.musc.list") or die "Could not create newfile $!\n";
	while(defined($in_line=<IN>))
	{
		chomp($in_line);
		$query = ();
		$query = $in_line;	
		
		system("cat $query*ffn > $query.fa");
		print OUT "$query.fa.musc.muscII\n";
	
	}
	close (IN);
	close (OUT);
	system("mkdir Concat_fa_files");
	system("cp *.fa ./Concat_fa_files");
	system("cp *musc.list ./Concat_fa_files");
	
}