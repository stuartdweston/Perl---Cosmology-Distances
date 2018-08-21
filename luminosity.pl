#!/usr/local/bin/perl

#use strict; 
use Math::Trig;

# For a given Z calulate the luminosity distance
# Check with: http://www.astro.ucla.edu/~wright/ACC.html

# From a fortran program by Benjamin Weiner
# http://mingus.as.arizona.edu/~bjw/software/
# DISTCALC - calculate luminosity distances and such
#            see David Hogg's paper, astro-ph/9905116

# Ported to Perl Sept 2012
# S.D.Weston - AUT University

sub luminosity_distance {
    
      $maxnum=700000;
      $AUTOPAR=0;
      
      $pi = 3.1415926535897932384626433832795;
      $fourpi = 4.0*$pi;
	  	  
      $nmax=$maxnum;

# Clear arrays
      @ez=();
	  @dc=();
	  @tlookback=();
	  @dm=();
	  @da=();
	  @dl=();
	  @distmod=();
	  @dvc=();
	  @vc=();
	  
# set params automatically
# hubble constant      
         $h = 0.7;
# univ type: omegam, omegal 
# 1:(1,0), 2:(0.05,0), 3(0.2,0.8), 4(0.3,0.7)
         $iuniverse = 4;
# omega_mass = 8pi G rho_0 / 3H_0**2, omega_lambda = Lambda c**2 / 3H_0**2
         if ($iuniverse==1) {
            $omegam = 1.0;
            $omegal = 0.0;
		 }
         elsif ($iuniverse==2) {
            $omegam = 0.05;
            $omegal = 0.0;
			}
         elsif ($iuniverse==3) {
            $omegam = 0.2;
            $omegal = 0.8;
			}
         else {
            $omegam = 0.3;
            $omegal = 0.7;
			}
         

      $omegak = 1.0 - $omegam - $omegal;

      $ckms = 3.0e5;
      $h0kms = 100.*$h;
#      $h0sec = $h0kms / 3.086e18;
#      1Mpc = 3.086e19km's, the above 1pc=3.086e18cm !
       $h0sec = $h0kms / 3.086e19;
	  
# Hubble distance in Mpc
      $dhmpc = $ckms / $h0kms;
	  
# Hubble time in sec
      $thsec = 1.0 / $h0sec;
      $thgyr = $thsec / (3600.0 * 24.0 * 365.0) / 1.0e9;
	
# Setup for Integration !

     $dz = 0.00001;
     $z0 = 0.0;
	 $zmax = $_[0];
	 
	 # printf "Red Shift      : %6.4f \n",$zmax;

	 $nzmax = int(($zmax-$z0)/$dz) + 1;
     
	 if ($nzmax>$nmax) {
	     print "nzmax : ",$nzmax,"\n";
		 print "nmax  : ",$nmax,"\n";
         print "Too small dz / too small array \n";
         exit 1;
      }
      
	 for($i=0;$i<$nzmax;$i++) {
         $z[$i] = $z0+$i*$dz;
#		 print "z :",$z[$i],"\n";
      }
	  
#  comoving line-of-sight distance Dc = Dh * integral(0,z, dz'/E(z'))
#  Bogus not-really-integrating for the moment

    $ez0 = escale(0.0,$omegam,$omegal,$omegak);
	$ez[0] = escale($z[0],$omegam,$omegal,$omegak);

    $dc[0] = $dhmpc * $dz * (1.0/$ez[0] + 1.0/$ez0) / 2.0;
    $tlookback[0] = $thgyr * $dz * ( 1.0/(1.0+$z[0])/$ez[0] + 1.0/$ez0) / 2.0;

		      
	for($i=0;$i<$nzmax;$i++) {
	
	     $ez[$i] = escale($z[$i],$omegam,$omegal,$omegak);
         $dc[$i] = $dc[$i-1] + $dhmpc * $dz * (1.0/$ez[$i] + 1.0/$ez[i-1]) / 2.0;
		 
		 $tlookback[$i] = $tlookback[$i-1] + $thgyr * $dz * ( 1.0/(1.0+$z[$i])/$ez[$i] + 1.0/(1.0+$z[$i-1])/$ez[$i-1]) / 2.0;
		 
      }
	  
      for($i=0;$i<$nzmax;$i++) {
	  
#  		transverse comoving distance
         if (abs($omegak)<1.0e-4) {
            $dm[$i] = $dc[$i];
			}
         elsif ($omegak>0.0) {
            $dm[$i] = $dhmpc / sqrt($omegak) * sinh(sqrt($omegak)*$dc[$i]/$dhmpc);
			}
         else {
            $dm[$i] = $dhmpc / sqrt(abs($omegak)) * sin(sqrt(abs($omegak))*$dc[$i]/$dhmpc);
         }
		 
#		angular diameter distance
         $da[$i] = $dm[$i] / (1.0+$z[$i]);
		 
#  		luminosity distance
         $dl[$i] = $dm[$i] * (1.0+$z[$i]);
		 
#  		distance modulus.  dl[$i] is in Mpc and magnitudes are referred to 10 pc.
         $distmod[$i] = 5.0 * log10($dl[$i]*1.0e5);
		 
#  		comoving volume element, one needs to multiply this by
#  		dOmega dz (i.e. solid angle * dz) to get dV_c
         $dvc[$i] = $dhmpc*(1.+$z[$i])**2*$da[$i]**2/$ez[$i];
		 
# 		actual integrated comoving volume, out to redshift z, over
# 		the whole sky (so multiply by dOmega/4pi for a given solid angle)

         if (abs($omegak) < 1.0e-4) {
            $vc[$i] = $fourpi/3.0 * $dm[$i]**3;
			}
         else { 
            $tmp1 = $fourpi * $dhmpc**3 / 2.0 / $omegak;
            $tmp2 = $dm[$i]/$dhmpc * sqrt(1.0+$omegak*($dm[$i]/$dhmpc)**2);
            $tmp3 = sqrt(abs($omegak)) * $dm[$i] / $dhmpc;
			
            if ($omegak > 0.0) {
               $vc[$i] = $tmp1 * ($tmp2 - 1.0/sqrt(abs($omegak))*asinh($tmp3));
			   }
            else {
               $vc[$i] = $tmp1*($tmp2 - 1.0/sqrt(abs($omegak))*asin($tmp3));
               }
			   
            } 
          
      }

#    Write out the result
	  
      $dzprint=1000;
      $nprint = nint($dzprint/$z);

	  
#     print "nzmax : ",$nzmax,"\n";
 
=comment
 
	  printf  "%-6s %-11s %-11s %-11s %-11s %-11s %-11s %-11s %-11s \n","Z","DC","DM","DA","DL","DistMod","DVC","VC","tlookback";
	  

	  $linecount=0;
	  
	  for($i=0;$i<=$nzmax;$i++) {
	           
			   if($linecount==24){
			      $linecount=0;
				  printf "\n";
				  printf  "%-6s %-11s %-11s %-11s %-11s %-11s %-11s %-11s %-11s \n","Z","DC","DM","DA","DL","DistMod","DVC","VC","tlookback";
				  }
				  
	           printf  "%6.4f %11.4e %11.4e %11.4e %11.4e %11.4e %11.4e %11.4e %11.4e \n",
			   $z[$i],$dc[$i],$dm[$i],$da[$i],$dl[$i],$distmod[$i],$dvc[$i],$vc[$i],$tlookback[$i];
#			   $i=$i+$nprint;
			   $linecount++;
      }
=cut
	  
	 
	  $l=$nzmax-1;
#	  printf  "%6.4f %11.4e %11.4e %11.4e %11.4e %11.4e %11.4e %11.4e %11.4e \n",
#			   $z[$l],$dc[$l],$dm[$l],$da[$l],$dl[$l],$distmod[$l],$dvc[$l],$vc[$l],$tlookback[$l];
			   
#	  printf "Returning Dl vc: %11.4e %11.4e\n",$dl[$l],$vc[$l];
      return $dl[$l],$vc[$l];

}
	  
#----------
#  calculate function E(z)
#  function escale((z,omegam,omegal,omegak)

   sub escale
   {
	  
      ($z,$omegam, $omegal,$omegak)=@_; 
#	  print "z, omegam, omegal, omegak : ",$z," ",$omegam," ", $omegal," ",$omegak,"\n";
	  $esq = $omegam*(1.0+$z)**3 + $omegal + $omegak*(1.0+$z)**2;
      return sqrt($esq);
	  
    }
	  

#----------
#  function log10(x)

sub log10 {
    my $n=shift;
	return log($n)/log(10);
}

#----------
#  function nint(x)
#  I copied from: http://hea-www.harvard.edu/~alexey/calc-src.txt

sub nint {
  my $x = $_[0]; 
  my $n = int($x);
  if ( $x > 0 ) {
    if ( $x-$n > 0.5) {
      return $n+1;
    }
    else {
      return $n;
    }
  }
  else {
    if ( $n-$x > 0.5) {
      return $n-1;
    }
    else {
      return $n;
    }
  }
}

sub max ($$) { $_[$_[0] < $_[1]] }
sub min ($$) { $_[$_[0] > $_[1]] }
1;
         
