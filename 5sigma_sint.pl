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
 
  
for(my $Redshift=0.01; $Redshift <=1.0; $Redshift=$Redshift+0.01) {

     
# for atlas_radio_specz

# Mao et al 0.15mJy
#   my $Sint_mJy=0.15;
# Franzen et al 2015, ATLAS DR3 CDFS simga=14.9 uJy, 5sigma=74.9uJy
#                               ELAIS sigma=17 uJy, 5 sigma=85uJy
#     my $Sint_mJy=0.0749; # CDFS
	 my $Sint_mJy=0.085; # ELAIS
     
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
	
     printf " %6.4f %13.8e     %13.8e %13.8e\n",$Redshift,$Lv,$LogLv,$CV;
}
print "done\n";