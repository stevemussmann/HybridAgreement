#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Std;
#use Data::Dumper;

# kill program and print help if no command line arguments were given
if( scalar( @ARGV ) == 0 ){
  &help;
  die "Exiting program because no command line options were used.\n\n";
}

# take command line arguments
my %opts;
getopts( 'c:hl:o:r:s:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $cat, $labels, $out, $rfile, $structure ) = &parsecom( \%opts );

my @rLines;
my @lLines;
my @sLines;
my @cLines;

my %lHash;
my %sHash;
my %cHash;

&filetoarray( $rfile, \@rLines );
&filetoarray( $labels, \@lLines );
&filetoarray( $structure, \@sLines );
&filetoarray( $cat, \@cLines );

foreach my $line( @lLines ){
	my @temp = split( /\s+/, $line );
	$lHash{$temp[0]} = $temp[1];
}

foreach my $line( @sLines ){
	my @temp = split( /\s+/, $line );
	$sHash{$temp[0]} = $temp[1];
}

foreach my $line( @cLines ){
	my @temp = split( /\s+/, $line );
	$cHash{$temp[0]} = $temp[1];
}

open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";

my $header = shift( @rLines );

my @oldheader = split( /,/, $header );
my @newHeader;
push( @newHeader, "Sample" );
push( @newHeader, "Best_Class" );
push( @newHeader, "Population" );
push( @newHeader, "Pr(Best_Class)" );
push( @newHeader, "logLikelihood" );

for( my $i=2; $i<7; $i++ ){
	$oldheader[$i] =~ s/\"//g;
	my @temp2 = split( /\./, $oldheader[$i] );
	shift( @temp2 );
	my $newcat = join( ".", @temp2 );
	$newcat =~ s/A\.0/A\-0/g;
	push( @newHeader, $cHash{$newcat} );
}

push( @newHeader, "converged" );
push( @newHeader, "n.iter" );
push( @newHeader, "n.param" );

my $newheaderstring = join( "\t", @newHeader );
print OUT $newheaderstring, "\n";

foreach my $line( @rLines ){
	$line =~ s/\"//g;
	my @temp = split( /,/, $line );
	$temp[1] = $cHash{$temp[1]};
	my $prob = &getProb(\@temp);
	splice( @temp, 2, 0, $lHash{$sHash{$temp[0]}} );
	splice( @temp, 3, 0, $prob );
	my $newstring = join( "\t", @temp );
	print OUT $newstring, "\n";
}

close OUT;

#print Dumper(\%cHash);

exit;
#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nlabelSnapclust.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -c | -h | -l | -o | -r | -s ]\n\n";
  print "\t-c:\tSpecify the category file (required, default = category.txt).\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-l:\tSpecify the sample labels file (required, default = newlabels.txt).\n\n";
  print "\t-o:\tSpecify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".cat.csv\" will be appended to the input file name.\n\n";
  print "\t-r:\tSpecify the snapclust results file (required).\n\n";
  print "\t-s:\tSpecify the structure input file (required).\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $rfile = $opts{r} || die "Snapclust results file not specified."; #specify snapclust results file
  my $labels = $opts{l} || "newlabels.txt"; #specify file of new labels
  my $structure = $opts{s} || die "Structure file used as snapclust input not specified."; #used to specify structure file
  my $cat = $opts{c} || "category.txt";
  my $out = $opts{o} || "$rfile.cat.csv"; #specify output file

  return( $cat, $labels, $out, $rfile, $structure );

}

#####################################################################################################
# subroutine to put file into an array

sub filetoarray{

  my( $infile, $array ) = @_;


  # open the input file
  open( FILE, $infile ) or die "Can't open $infile: $!\n\n";

  # loop through input file, pushing lines onto array
  while( my $line = <FILE> ){
    chomp( $line );
    next if($line =~ /^\s*$/);
    push( @$array, $line );
  }

  # close input file
  close FILE;

}

#####################################################################################################
# subroutine to get assignment probability for best classification from snapclust file

sub getProb{

	my( $array ) = @_;

	my $max = 0.0;

	for( my $i=3; $i<8; $i++ ){
		if( $$array[$i] > $max ){
			$max = $$array[$i]
		}
	}

	return( $max );

}

#####################################################################################################

