use strict;
use warnings;

# Define some constants

my $pi = 3.1415926535897932384626433832795;
my $fourpi = 4.0*$pi;
	  
# 1parsec = 3.08567758*10**16 meters

my $pc=3.08567758*10**16;
my $Mpc=$pc*10**6;
	  
# 1Jy = 10**-26 W/m.Hz

my $jy=10**-26;
	  
# spectral index

my $alpha = -0.75;

# We need this one I think
	  
require 'luminosity.pl';
 
my $filename = 'atlas_dr3_cdfs_ozdes_z.csv';

open(my $fh, '<:encoding(UTF-8)', $filename)
  or die "Could not open file '$filename' $!";

printf " id    Sint(mJy) z      Lv   Log(Lv) ComovingVolume \n";
  
while (my $row = <$fh>) {
     chomp $row;

# need to skip the first row

#     if (index($row,'cid') != -1) {next};
     if (index($row,'Sp') != -1) {next};
     
     my @array=split(',',$row);
 
# if Sint = -999 then use Sp (peak flux)
     my $Sint_mJy;
	 my $Redshift;
     if($array[1] < 0.0) {
         $Sint_mJy=$array[0]*1;  
         $Redshift=$array[3]*1; 
     } else {
         $Sint_mJy=$array[1]*1;  
         $Redshift=$array[3]*1; 
	 }
     
#  print "Str : Sint : @array[3]       Redshift : @array[8]\n";
#  print "Real: Sint : $Sint_mJy       Redshift : $Redshift\n";
  
# OK need to do the cosmological calculations now

     my ($Dl, $CV)=luminosity_distance($Redshift);
	 
#	 printf "Luminosity Distance : %13.8e Mpc\n",$Dl;
	 # This returns Dl in Mpc, so need to convert to meters
	 $Dl=$Dl*$Mpc;
	 
#	 printf "Luminosity Distance : %13.8e m\n",$Dl;
	 
	 #S20 Flux is in mJy, so need to convert to W/Hz
	 my $S20=$Sint_mJy*10**-3;
	 $S20=$S20*$jy;
	 
	 my $Lv=($fourpi*$S20*($Dl**2))/((1+$Redshift)**(1+$alpha));
#	 printf "Luminosity Function : %13.8e W/Hz\n",$Lv;
	 my $LogLv=log10($Lv);
	
#	 print "Log LF                : $LogLv\n";
#     printf " %8s    %6.4f %13.8e     %13.8e %13.8e\n",$array[0],$array[2],$Redshift,$Lv,$LogLv,$CV;
     printf " %8s    %6.4f %13.8e     %13.8e %13.8e\n",$array[0],$array[3],$Redshift,$Lv,$LogLv,$CV;
}
print "done\n";