# Bio-Deago

DEAGO generates a user-friendly HTML report from differential expression ([DESeq2](https://bioconductor.org/packages/release/bioc/html/DESeq2.html)) and GO term enrichment ([topGO](http://bioconductor.org/packages/release/bioc/html/topGO.html)) analysis of RNA-Seq data.

## Installation

DEAGO has the following dependencies:

* [pandoc](http://pandoc.org/installing.html) >= 1.12.3 
* [R](https://www.r-project.org) >= 3.4.0 
* [deago](https://github.com/sanger-pathogens/deago)

### Environment variables

By default, DEAGO will look for R in your `$PATH` and for the associated R libraries in `$R_LIBS`. Where there are multiple R versions or libraries installed, setting the environment variables below will enable you to overwrite this default behaviour.

| Dependency | Environment variable    | Example                |
| :----------| :---------------------- | ---------------------- |
| R bin      | DEAGO_R                 | /path/to/R-3.4.0/bin   |
| R library  | DEAGO_R_LIBS            | /path/to/personal/rlib |

## Input data

To run DEAGO, the user must provide a path to the read count matrices for each sample and a sample/condition mapping file. For GO term enrichment analysis, an annotation file must also be provided.

| Input                           | Description                                                       |
| :------------------------------ | :---------------------------------------------------------------- |
| count data directory (required) | path to directory containing count matrix files (one per sample)  |
| targets file (required)         | sample to experimental condition mappings                         |
| annotation file (optional)      | required for gene name annotation and GO term enrichment analysis |

Please read the [DEAGO wiki](https://github.com/sanger-pathogens/deago/wiki) for more information on the required file formats.

## Quick start 

To run QC and differential expression analyses:

`deago --build_config -c <path/to/count/data> -t <sample_mapping.txt>`

## QC only

To only generate QC plots:

`deago --build_config -c <path/to/count/data> -t <sample_mapping.txt> --qc`

## Convert BioMart annotation

To convert a delimited annotation file (e.g. BioMart):

`deago --build_config -c <path/to/count/data> -t <sample_mapping.txt> --convert_annotation -a <annotation.txt>`

## GO term enrichment analysis

GO term enrichment analysis requires an annotation file mapping the gene identifiers in the count matrices with their associated GO terms.

`deago --build_config -c <path/to/count/data> -t <sample_mapping.txt> -a <annotation_file.txt> --go`

## Output files

DEAGO generates a user-friendly HTML report of the analysis (**deago_markdown.html**). The markdown file used to run the analysis and knit the report is also provided (**deago_markdown.Rmd**) along with a log file containing the STDOUT from the conversion. If `--build-config` was used instead of providing a configuration file, then a configuration file will be generated (**deago.config**).

| File(s)                          | Description                                   |
| :------------------------------- | :-------------------------------------------- |
| deago.config (optional)          | Key/value parameters to define the analysis   |
| deago_markdown.Rmd               | R markdown file of analysis commands          |
| deago_markdown.html              | HTML report knitted from R markdown file      |
| deago.rlog                       | Log file of STDOUT from R markdown conversion |

Differential expression and GO term enrichment analysis results are written to tab-delimited files within a timestamped results directory (results_<timestamp>). The corresponding results directory can be found in the **Pipeline configuration** section of the HTML report.

| File(s)                        | Description                                                    |
| :----------------------------- | :------------------------------------------------------------- |
| \<contrast\>_\<alpha\>.txt     | Differential expression analysis results and normalised counts |
| \<contrast\>_\<go_level\>.tsv  | GO term enrichment analysis results                            |

For more information, please go to the [DEAGO wiki](https://github.com/sanger-pathogens/deago/wiki).

[![Build Status](https://travis-ci.org/sanger-pathogens/Bio-Deago.svg?branch=master)](https://travis-ci.org/sanger-pathogens/Bio-Deago)