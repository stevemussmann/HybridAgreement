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
getopts( 'a:d:hm:n:s:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $agree, $disagree, $matrix, $newhyb, $snap ) = &parsecom( \%opts );

my @nLines;
my @sLines;

my %ncHash;
my %npHash;
my %scHash;
my %spHash;
my %popHash;

my %compHash; #key1 = newhybrids_result, key2 = snapclust_result

my %classHash;

&filetoarray( $newhyb, \@nLines );
&filetoarray( $snap, \@sLines );

my $nHeader = shift( @nLines );
foreach my $line( @nLines ){
	my @temp = split( /\t/, $line );
	$ncHash{$temp[0]} = $temp[1];
	$npHash{$temp[0]} = sprintf("%.5f", $temp[3] );
	$popHash{$temp[0]} = $temp[2];
	$classHash{$temp[1]}++; # used to populate empty %compHash so that printed matrix has all cells filled in.
}

my $sHeader = shift( @sLines );
foreach my $line( @sLines ){
	my @temp = split( /\t/, $line );
	$scHash{$temp[0]} = $temp[1];
	$spHash{$temp[0]} = sprintf("%.5f", $temp[3] );
	$classHash{$temp[1]}++;
}

# populate compHash with zeroes for all comparisons. 
foreach my $class1( sort keys %classHash ){
	foreach my $class2( sort keys %classHash ){
		$compHash{$class1}{$class2} = 0;
	}
}

open( DISAGREE, '>', $disagree ) or die "Can't open $disagree: $!\n\n";
open( AGREE, '>', $agree ) or die "Can't open $agree: $!\n\n";
open( MATRIX, '>', $matrix ) or die "Can't open $matrix: $!\n\n";
print DISAGREE "Individual\tPopulation\tNH_class\tNH_prob\tSC_class\tSC_prob\n";
print AGREE "Individual\tPopulation\tNH_class\tNH_prob\tSC_class\tSC_prob\n";

# print text files with agreements and disagreements
foreach my $ind( sort keys %ncHash ){
	if( $ncHash{$ind} ne $scHash{$ind} ){
		print DISAGREE $ind, "\t", $popHash{$ind}, "\t", $ncHash{$ind}, "\t", $npHash{$ind}, "\t", $scHash{$ind}, "\t", $spHash{$ind}, "\n";
		$compHash{$ncHash{$ind}}{$scHash{$ind}}++;
	}else{
		print AGREE $ind, "\t", $popHash{$ind}, "\t", $ncHash{$ind}, "\t", $npHash{$ind}, "\t", $scHash{$ind}, "\t", $spHash{$ind}, "\n";
		$compHash{$ncHash{$ind}}{$scHash{$ind}}++;
	}
}

#print matrix of comparisons. Newhybrids = rows; Snapclust = columns
foreach my $nhClass( sort keys %compHash ){
	print MATRIX $nhClass;
	foreach my $scClass( sort keys %{$compHash{$nhClass}} ){
		print MATRIX "\t", $compHash{$nhClass}{$scClass};
	}
	print MATRIX "\n";
}

close DISAGREE;
close AGREE;
close MATRIX;

print "\nSamples with classifications agreeing in both Newhybrids and Snapclust printed to ", $agree, ".\n\n";
print "Samples with disagreeing classifications printed to ", $disagree, ".\n\n";
print "Agreement matrix printed to ", $matrix, ".\n";
print "Rows = NewHybrids assignments.\n";
print "Columns = Snapclust assignments.\n\n";

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{

  print "\ncompareSnapclustNewhybrids.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -a | -d | -h | -m | -n | -s ]\n\n";
  print "\t-a:\tSpecify the file to which samples in agreement will be printed (required, default = agree.txt.\n\n";
  print "\t-d:\tSpecify the file to which disagreeing samples will be printed (required, default = disagree.txt.\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-m:\tSpecify the file to which the agreement matrix will be printedcontaining NewHybrids results (required).\n\n";
  print "\t-n:\tSpecify the file containing NewHybrids results (required).\n\n";
  print "\t-s:\tSpecify the file containing Snapclust results (required).\n\n";

}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{

  my( $params ) =  @_;
  my %opts = %$params;

  # set default values for command line arguments
  my $agree = $opts{a} || "agree.txt"; # write out agreeing classifications
  my $disagree = $opts{d} || "disagree.txt"; # write out disagreeing classifications.
  my $matrix = $opts{m} || "matrix.txt"; # write out agreement matrix.
  my $newhyb = $opts{n} || die "NewHybrids results not specified.\n\n"; #used to specify input file name.
  my $snap = $opts{s} || die "Snapclust results not specified.\n\n"; #used to specify input file name.

  return( $agree, $disagree, $matrix, $newhyb, $snap );

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
