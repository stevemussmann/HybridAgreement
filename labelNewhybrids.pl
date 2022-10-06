#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Std;
use Data::Dumper;

# kill program and print help if no command line arguments were given
if( scalar( @ARGV ) == 0 ){
  &help;
  die "Exiting program because no command line options were used.\n\n";
}

# take command line arguments
my %opts;
getopts( 'a:c:hp:o:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $pofz, $cat, $map, $out ) = &parsecom( \%opts );

my @pofzLines;
my @catLines;
my @mapLines;

my %catHash;

&filetoarray( $pofz, \@pofzLines );
&filetoarray( $cat, \@catLines );
&filetoarray( $map, \@mapLines );

# remove header line from category file
shift( @catLines );
foreach my $line( @catLines ){
	my @temp = split( /\s+/, $line );
	my $category = shift( @temp );
	for( my $i=0; $i<@temp; $i++ ){
		$temp[$i] = sprintf("%.3f", $temp[$i]);
	}
	my $string = join("/", @temp );
	$catHash{$string} = $category;
}

# remove header line from pofz file
my @header = split( /\s+/, shift( @pofzLines ) );
if( scalar(@pofzLines) != scalar(@mapLines) ){
	die "Different number of records in $pofz and $map. Are these the correct files?\n\n";
}

open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";

#print new header
my @newHeader;
push( @newHeader, "Sample" );
push( @newHeader, "Best_Class" );
push( @newHeader, "Population" );
push( @newHeader, "Pr(Best_Class)" );
for( my $i=2; $i<@header; $i++ ){
	push( @newHeader, $catHash{$header[$i]} );
}

my $newheaderstring = join( "\t", @newHeader );
print OUT $newheaderstring, "\n";

for( my $i=0; $i<@pofzLines; $i++ ){
	my @newLine;
	my @temp = split( /\s+/, $pofzLines[$i] );
	my @info = split( /\s+/, $mapLines[$i] );

	push( @newLine, $info[0] );

	my( $category, $prob ) = &getCat( \@temp, \%catHash, \@header );
	push( @newLine, $category );
	push( @newLine, $info[1] );
	push( @newLine, $prob );

	for( my $j=2; $j<@temp; $j++ ){
		push( @newLine, $temp[$j] );
	}

	my $printstring = join( "\t", @newLine );
	print OUT $printstring, "\n";

}

close OUT;

#print Dumper( \%catHash );
#print Dumper( \@header );

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{

  print "\ngenepop2newhybrids.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -a | -c | -h | -p | -o ]\n\n";
  print "\t-a:\tSpecify the aa-PofZ.txt file from NewHybrids (required; default=aa-PofZ.txt).\n\n";
  print "\t-c:\tSpecify the genotype frequency category file used for NewHybrids (required; default=TwoGensGtypFreq.txt).\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-p\tSpecify a popmap file (sampleName<tab>population) sorted in the same order individuals appear in aa-PofZ.txt (required).\n\n";
  print "\t-o:\tSpecify the output file name. (optional)\n";
  print "\t\tIf no name is provided, output will be written to\"newhybrids.result.labeled.txt\".\n\n";

}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{

  my( $params ) =  @_;
  my %opts = %$params;

  # set default values for command line arguments
  my $pofz = $opts{a} || "aa-PofZ.txt"  ; #NewHybrids probabilities file
  my $cat = $opts{c} || "TwoGensGtypFreq.txt"  ; #NewHybrids category file
  my $map = $opts{p} || die "No population map provided.\n\n"; #population map
  my $out = $opts{o} || "newhybrids.result.labeled.txt"  ; #used to specify output file name.

  return( $pofz, $cat, $map, $out );

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
# subroutine to get assignment category from newHybrids results file

sub getCat{

	my( $input, $hash, $header) = @_;

	my $max = 0.0;
	my $val = 0;
	my $category = "None";
	for( my $i=2; $i<@$input; $i++ ){
		if( $$input[$i] > $max ){
			$max = $$input[$i];
			$val = $i;
			$category = $$hash{$$header[$i]};
		}
	}

	
	return( $category, $max );
}

#####################################################################################################
