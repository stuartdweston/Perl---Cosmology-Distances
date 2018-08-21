# Example to select from a MySQL database
# Example from: http://perl.about.com/od/perltutorials/a/perlmysql_3.htm
#!/usr/bin/perl -w
 use DBI;
 use Statistics::LineFit;
 
      $pi = 3.1415926535897932384626433832795;
      $fourpi = 4.0*$pi;
	  
	  # 1parsec = 3.08567758*10**16 meters
	  $pc=3.08567758*10**16;
	  $Mpc=$pc*10**6;
	  
      # 1Jy = 10**-26 W/m.Hz
      $jy=10**-26;
	  
	  # spectral index
	  $alpha = -0.75;
	  
 require 'luminosity.pl';
 
 #printf "1pc : %13.8e m\n",$pc;
 
 #$dbh = DBI->connect('dbi:mysql:ecdfs','atlas','atlas')
 
 $dbh = DBI->connect('dbi:mysql:ecdfs','root','m@nc1ty')
 or die "Connection Error: $DBI::errstr\n";
 
 $sql = "select sid,S20,z,logL1_4 from atlas.atlas_radio_specz order by z limit 11,10000 ";
 
 $sth = $dbh->prepare($sql);
 $sth->execute
 or die "SQL Error: $DBI::errstr\n";
 
 $records=0;
 
 printf " z      LuminosityFunction  ComovingVolume  Log(Lv) \n";
 
 while (@row = $sth->fetchrow_array) {
 #print "\n\nMinnie's Data - sid: $row[0]    S20: $row[1]     z: $row[2]   logL1_4: $row[3]\n";
 
     my ($Dl, $CV)=luminosity_distance($row[2]);
	 
#	 printf "Luminosity Distance : %13.8e Mpc\n",$Dl;
	 # This returns Dl in Mpc, so need to convert to meters
	 $Dl=$Dl*$Mpc;
	 
#	 printf "Luminosity Distance : %13.8e m\n",$Dl;
	 
	 #S20 Flux is in mJy, so need to convert to W/Hz
	 $S20=$row[1]*10**-3;
	 $S20=$S20*$jy;
	 $A_S20[$records]=$S20;
	 
	 $Lv=($fourpi*$S20*($Dl**2))/((1+$row[2])**(1+$alpha));
#	 printf "Luminosity Function : %13.8e W/Hz\n",$Lv;
	 $LogLv=log10($Lv);
	 $A_LogLv[$records]=log10($Lv);
	
#	 print "Log LF                : $LogLv\n";

     printf " %s %6.4f %13.8e     %13.8e %13.8e\n",$row[0],$row[1],$Lv,$LogLv,$CV;
	 
#    Insert into database

     my $insert_sql="insert into atlas.sw_atlas_radio values (?,?,?,?)";
	 my $insert_sth=$dbh->prepare($insert_sql);
	 
	 $insert_sth->execute($row[0],$Lv,$LogLv,$CV);
	 
	 $records++;
	 
 } 