use DBI;
  
      $pi = 3.1415926535897932384626433832795;
      $fourpi = 4.0*$pi;
	  
	  # 1parsec = 3.08567758*10**16 meters
	  $pc=3.08567758*10**16;
	  $Mpc=$pc*10**6;
	  
      # 1Jy = 10**-26 W/m.Hz
      $jy=10**-26;
	  
	  # spectral index
	  $alpha = -0.75;
	  
  $dbh = DBI->connect('dbi:mysql:ecdfs','root','m@nc1ty')
 or die "Connection Error: $DBI::errstr\n";
 
 my $inc=0.5;
 my $LogL1_4=21.0;
 
 for ($counter=1; $counter<13;$counter++) {
 
    $lowlim=$LogL1_4;
	$upperlim=$LogL1_4+0.5;
	
	#print " $lowlim $upperlim \n";
	
    $sql = "select count(*) from atlas.sw_atlas_radio where logL1_4 > $lowlim and logL1_4 < $upperlim ; ";
	#print " $sql \n";
 
    $sth = $dbh->prepare($sql);
	
	$sth->execute
	or die "SQL Error: $DBI::errstr\n";
	
	@row = $sth->fetchrow_array;
	$N=log10($row[0]);
	printf ("%.1f %.4f\n",$LogL1_4,$N);
	
	#----
	
	$sql = "select sum(1/cv) from atlas.sw_atlas_radio where logL1_4 > $lowlim and logL1_4 < $upperlim ; ";
	 
    $sth = $dbh->prepare($sql);
	
	$sth->execute
	or die "SQL Error: $DBI::errstr\n";
	
	@row = $sth->fetchrow_array;
	$avg_cv=$row[0];
	#print "Average CV : $avg_cv\n";
	
	$phi=log10($avg_cv);
	#print "phi        : $phi\n";
	
	$LogL1_4=$LogL1_4+$inc;
 
 }
 
#----------
#  function log10(x)

sub log10 {
    my $n=shift;
	return log($n)/log(10);
}

 