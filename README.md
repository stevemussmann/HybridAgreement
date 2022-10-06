# HybridAgreement
Scripts for comparing hybrid classification results from Snapclust and NewHybrids

## Requirements
perl
R >= 4.0
adegenet R package
optparse R package

## Basic Procedure
Below is the basic order of operations for running the scripts in this repository. Additional information and example files for some of the inputs will be added over time.
1. Run NewHybrids
2. Run SnapClust from a structure-formatted file (one row per individual, header row of marker names, 1st column = sample ID, 2nd column = population ID) using the `snapclust_detectHybrids.R` script.
3. Use `labelNewhybrids.pl` to reassociate sample names/populations and determine clasification of highest probability for each sample. 
4. Use `labelSnapclust.pl` do the same for the snapclust results.
5. Run `compareSnapclustNewhybrids.pl` to identify agreements and disagreements among snapclust and newhybrids results. 
