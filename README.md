# Bio-Deago

[![Build Status](https://travis-ci.org/sanger-pathogens/Bio-Deago.svg?branch=master)](https://travis-ci.org/sanger-pathogens/Bio-Deago)

DEAGO generates a user-friendly HTML report from differential expression and GO term enrichment analysis of RNA-Seq data.

## Installation

Dependencies:
	- pandoc >= 1.12.3 (http://pandoc.org)
	- deago (https://github.com/sanger-pathogens/deago)
	- R >= 3.4.0 (https://www.r-project.org)

Pandoc <http://pandoc.org> (>= 1.12.3) is required for the R package 'rmarkdown' <https://github.com/rstudio/rmarkdown>.  Installation instructions for pandoc are available 'here' <https://github.com/rstudio/rmarkdown/blob/master/PANDOC.md> and 'here' <http://pandoc.org/installing.html>.

If you get the error "" during the conversion of the R markdown file to the HTML report, please check that your R version is >= 3.4.0 and the Matrix R package is up to date.


