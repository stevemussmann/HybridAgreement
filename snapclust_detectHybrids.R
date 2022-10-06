#!/usr/local/bin/Rscript

library("adegenet")
library("optparse")

option_list = list(
	make_option(
		c("-f", "--file"),
		type="character",
		default=NULL,
		help="Structure file (one line per individual) containing genotype data.",
		metavar="character"
	),
	make_option(
		c("-o", "--out"),
		type="character",
		default="output",
		help="Output file prefix.",
		metavar="character"
	)
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

#number of lines in file, subtract 1 to account for header line
ninds <- length(readLines(opt$file))-1

#get number of loci in file
df <- read.table(opt$file, skip = 1, header = F)
nloci <- (ncol(df)-2)/2

# read in data file
data<-read.structure(
	opt$file,
	n.ind=ninds,
	n.loc=nloci,
	onerowperind=TRUE,
	col.lab=1,
	col.pop=2,
	row.marknames=1,
	NA.char="-9",
	ask=FALSE
)

# run snapclust
res.hyb<-snapclust(data, k=2, hybrids=TRUE, hybrid.coef = c(0.25, 0.50))

# make output file names
outcsv = paste(opt$out, "results", "csv", sep = ".")
outplot = paste(opt$out, "compoplot", "pdf", sep = ".")

# write text output to csv
write.table(res.hyb, outcsv, append=FALSE, sep=",", row.names = TRUE, col.names = TRUE)

# write compoplot to pdf
pdf(outplot)
compoplot(res.hyb, col.pal = hybridpal(), n.col = 2)
dev.off()

quit()
