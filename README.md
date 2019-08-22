# Bio-Deago
Generate user-friendly HTML reports from differential expression and GO term enrichment analysis.

[![Build Status](https://travis-ci.org/sanger-pathogens/Bio-Deago.svg?branch=master)](https://travis-ci.org/sanger-pathogens/Bio-Deago)   
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-brightgreen.svg)](https://github.com/sanger-pathogens/Bio-Deago/blob/master/GPL-LICENSE)  
[![codecov](https://codecov.io/gh/sanger-pathogens/bio-deago/branch/master/graph/badge.svg)](https://codecov.io/gh/sanger-pathogens/bio-deago)   
[![https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg](https://www.singularity-hub.org/static/img/hosted-singularity--hub-%23e32929.svg)](https://singularity-hub.org/collections/3450)


## Contents
  * [Introduction](#introduction)
  * [Installation](#installation)
    * [Required dependencies](#required-dependencies)
    * [Environment variables](#environment-variables)
  * [Usage](#usage)
    * [Input data](#input-data)
    * [Quick start](#quick-start)
    * [QC only](#qc-only)
    * [Convert BioMart annotation](#convert-biomart-annotation)
    * [GO term enrichment analysis](#go-term-enrichment-analysis)
    * [Output files](#output-files)
  * [License](#license)
  * [Feedback/Issues](#feedbackissues)
  * [Further Information](#further-information)

## Introduction
DEAGO generates a user-friendly HTML report from differential expression ([DESeq2](https://bioconductor.org/packages/release/bioc/html/DESeq2.html)) and GO term enrichment ([topGO](http://bioconductor.org/packages/release/bioc/html/topGO.html)) analysis of RNA-Seq data.

## Installation
DEAGO has the following dependencies:

### Required dependencies
* [pandoc](http://pandoc.org/installing.html) >= 1.12.3 
* [R](https://www.r-project.org) >= 3.4.0 
* [deago](https://github.com/sanger-pathogens/deago)

Details to install DEAGO are provided below. If you encounter an issue when installing DEAGO please contact your local system administrator. If you encounter a bug please log it [here](https://github.com/sanger-pathogens/bio-deago/issues) or email us at path-help@sanger.ac.uk.

### From Source
Make sure you have installed all dependencies, then clone the repository:   
  
`git clone https://github.com/sanger-pathogens/Bio-Deago.git`   
  
Move into the directory and install all perl dependencies using [DistZilla](http://dzil.org/) and [cpanm](https://github.com/miyagawa/cpanminus):   
```
cd Bio-Deago
dzil authordeps --missing | cpanm
dzil listdeps --missing | cpanm
```
Run the tests:   
   
`dzil test`   
   
If the tests pass, install Bio-Deago:   
   
`dzil install`   
   
### Environment variables
By default, DEAGO will look for R in your `$PATH` and for the associated R libraries in `$R_LIBS`. Where there are multiple R versions or libraries installed, setting the environment variables below will enable you to overwrite this default behaviour.

| Dependency | Environment variable    | Example                |
| :----------| :---------------------- | ---------------------- |
| R bin      | DEAGO_R                 | /path/to/R-3.4.0/bin   |
| R library  | DEAGO_R_LIBS            | /path/to/personal/rlib |

## Usage
```
Usage: deago [options]
RNA-Seq differential expression qc and analysis

Main options:
  --output_directory (-o) output directory [.]
  --convert_annotation    convert annotation for use with deago (requires -a)
  --annotation_delim      annotation file delimiter [\t]
  --build_config          build configuration file from command line arguments (see configuration options)
  --config_file           configuration filename or output filename for configuration file if building [./deago.config]
  --markdown_file         output filename for markdown file [./deago_markdown.Rmd]
  --html_file             output filename for html file [./deago_markdown.html]
  -v                      verbose output to STDOUT
  -w                      print version and exit
  -h                      print help message and exit

Configuration options (required):
  -c STR          directory containing count files (absolute path)
  -t STR          targets filename (absolute path)

 Configuration options (optional):
  -r STR          results directory [current working directory]
  -a STR          annotation filename (absolute path)
  -q NUM          qvalue (DESeq2) [0.05]
  --control       name of control condition (must be present in targets file)
  --keep_images   keep images used in report
  --qc            QC only
  --go            GO term enrichment
  --go_levels     BP only, MF only or all [BP|MF|all]
  --count_type    type of count file [expression|featurecounts]
  --count_column  number of column containing count values
  --skip_lines    number of lines to skip in count file
  --count_delim   count file delimiter
  --gene_ids      name of column containing gene ids

DEAGO takes in a configuration file containing key/value pairs [default: ./deago.config]. You can
use your own configuration file with --config_file or specify parameters and let DEAGO build a
configuration file with --build_config (and --config_file if you don't want the default
configuration filename). For more information on configuration parameters run: build_deago_config -h.

DEAGO will then build a master R markdown file (--markdown_file if you don't want the default
markdown filename) from templates which utilize the companion DEAGO R package and the key/value
pairs set out in the configuration file. The R markdown will be processed and used to generate a
HTML report (--html_file if you don't want the default html filename).

To use custom gene names and for GO term enrichment (--go) and annotation file must be provided
(-a). Annotations downloaded from BioMart or those in a similar format can be converted for use
with DEAGO.  For more information run: mart_to_deago -h.
```
### Input data
To run DEAGO, the user must provide a path to the read count matrices for each sample and a sample/condition mapping file. For GO term enrichment analysis, an annotation file must also be provided.

| Input                           | Description                                                       |
| :------------------------------ | :---------------------------------------------------------------- |
| count data directory (required) | path to directory containing count matrix files (one per sample)  |
| targets file (required)         | sample to experimental condition mappings                         |
| annotation file (optional)      | required for gene name annotation and GO term enrichment analysis |

Please read the [DEAGO wiki](https://github.com/sanger-pathogens/deago/wiki) for more information on the required file formats.

### Quick start 

To run QC and differential expression analyses:

`deago --build_config -c <path/to/count/data> -t <sample_mapping.txt>`

### QC only

To only generate QC plots:

`deago --build_config -c <path/to/count/data> -t <sample_mapping.txt> --qc`

### Convert BioMart annotation

To convert a delimited annotation file (e.g. BioMart):

`deago --build_config -c <path/to/count/data> -t <sample_mapping.txt> --convert_annotation -a <annotation.txt>`

### GO term enrichment analysis

GO term enrichment analysis requires an annotation file mapping the gene identifiers in the count matrices with their associated GO terms.

`deago --build_config -c <path/to/count/data> -t <sample_mapping.txt> -a <annotation_file.txt> --go`

### Output files

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

## License
DEAGO is free software, licensed under [GPLv3](https://github.com/sanger-pathogens/Bio-Deago/blob/master/GPL-LICENSE).

## Feedback/Issues
Please report any issues to the [issues page](https://github.com/sanger-pathogens/Bio-Deago/issues) or email path-help@sanger.ac.uk.

## Further Information
For more information, please go to the [DEAGO wiki](https://github.com/sanger-pathogens/deago/wiki).
