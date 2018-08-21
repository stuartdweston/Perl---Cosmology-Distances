  use Astro::Cosmology qw( :constants );

  # what is the luminosity distance, in metres, for
  # a couple of cosmologies
  #
  my $z   = sequence(10) / 10;
  my $eds = Astro::Cosmology->new;
  my $sn  = Astro::Cosmology->new( matter => 0.3, lambda => 0.7 );

  my $de  = 1.0e6 * PARSEC * $eds->lum_dist($z);
  my $ds  = 1.0e6 * PARSEC * $sn->lum_dist($z);

  # let's change the parameters of the $sn cosmology
  $sn->setvars( lambda=>0.6, matter=>0.2 );